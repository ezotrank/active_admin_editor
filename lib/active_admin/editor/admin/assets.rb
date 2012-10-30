ActiveAdmin.register ImageAsset do
  menu parent: I18n.t('active_admin_editor.assets'), label: I18n.t('active_admin_editor.images')

  batch_action :destroy, false

  config.clear_sidebar_sections!

  index as: :grid do |image_asset|
    link_to(image_tag(image_asset.storage.thumb), admin_image_asset_path(image_asset))
  end

  form do |f|
    f.inputs do
      f.input :storage
    end

    f.buttons
  end

  show do
    attributes_table do
      row(t('active_admin_editor.dimensions')) do
        "#{image_asset.dimensions[:width]}X#{image_asset.dimensions[:height]}"
      end
      row(t('active_admin_editor.thumbnail')) do
        image_tag(image_asset.storage.thumb)
      end
      row('25%') do
        image_tag(image_asset.storage.one_quarter)
      end
      row('50%') do
        image_tag(image_asset.storage.half)
      end
      row('75%') do
        image_tag(image_asset.storage.three_quarters)
      end
      row('Full Image') do
        image_tag(image_asset.storage)
      end
    end
  end

  controller do

    def create
      # If an app is using Rack::RawUpload, it can just use
      # params['file'] and not worry with original_filename parsing.
      if params['file']
        @image_asset = ImageAsset.new
        @image_asset.storage = params['file']

        if @image_asset.save!
          render json: { success: true }.to_json
        else
          render nothing: true, status: 500 and return
        end
      elsif params['qqfile']
        @image_asset = ImageAsset.new
        io = request.env['rack.input']

        def io.original_filename=(name) @original_filename = name; end
        def io.original_filename() @original_filename; end

        io.original_filename = params['qqfile']

        @image_asset.storage = io
        if @image_asset.save!
          render json: { success: true }.to_json
        else
          render nothing: true, status: 500 and return
        end
      else
        create!
      end
    end

  end
end
