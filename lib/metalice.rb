module Metalice

  def render *args
    if render_except(args)
      method_name = meta_select_method_name
      set_meta( method_name ? send(method_name) : { :title => page_title_use } )
    end
    super
  end

  # 對應 method 前綴詞
  def meta_use_method_prefix
    "meta_for"
  end

  # 對應 method 名稱
  def meta_use_method_name(join_word = '_')
    "#{controller_path.underscore.gsub(/\//, join_word)}#{join_word}#{action_name}"
  end

  # 使用的 method_name 組合結構
  # 對應 method 有優先權
  # EX:
  #   1. Admin::FlagsController#show => meta_for_admin_flags_show
  #   2. Admin::FlagsController#show => meta_for_admin_flags
  #   3. Admin::FlagsController#show => meta_for_admin
  def meta_select_method_name
    Selector.priority MetaTagHelper, meta_use_method_name, { prefix_word: meta_use_method_prefix }
  end

  # 排除 render
  # - 使用 partial 的情況
  def render_except(args)
    return true if args[0].class.name == "String"
    !(args.present? ? args.at(0)[:partial].present? : false)
  end

  # =======================
  # meta結構
  def default_meta_makeup
    {
      title: nil,
      description: nil,
      keywords: nil,
      site: nil,
      og: {
        title: nil,
        description: nil,
        url: nil,
        type: nil,
        image: nil,
      },
      fb: {
        app_id: nil,
        admins: nil,
      },
      separator: " | ",
      reverse: true,
      url: nil,
    }
  end

  # 預設值控制
  def set_meta(data = {})
    meta = {}
    meta[:url] ||= url_for(params.merge(:host => Setting.host))
    meta[:title] ||= data.fetch(:title, page_title_use)
    meta[:og] = {}
    meta[:og][:url] ||= data.fetch(:og_url, "")
    meta[:og][:title] ||= data.fetch(:og_title, "")
    meta[:og][:description] ||= data.fetch(:og_description, "")
    meta[:og][:image] ||= data.fetch(:og_image, "")

    set_meta_tags default_meta_makeup.deep_merge(meta)
  end

  # =======================
  # 短字
  def short_word_use(obj, method_arr, length = 120)
    if obj.present?
      method_arr = [method_arr] if method_arr.class.name == "string"
      method_arr.each do |method|
        return ActionController::Base.helpers.truncate(ActionController::Base.helpers.strip_tags(obj.send(method.to_sym).to_s).squish, length: length) if obj.send(method.to_sym).present?
      end
    end
    meta_for_default[:description]
  end

  # 選圖
  def og_image_use(obj = nil, img_arr = ["og_image", "pic"])
    if obj.present?
      img_arr = [img_arr] if img_arr.class.name == "string"
      img_arr.each do |img|
        if obj.send(img.to_sym).present?
          obj_img = obj.send(img.to_sym)
          # MEMO 不能寫死http
          return (img == "og_image") ? "http:" + obj_img.url : "http:" + obj_img.large.url
        end
      end
    end
    asset_img("og_image.jpg")
  end

  # asset_path for image
  def asset_img(img, use_SSL = nil)
    prefix = use_SSL.nil? ? request.scheme.to_s : use_SSL.present? ? "https" : "http"
    prefix + ":" + ActionController::Base.helpers.asset_path(img)
  end

  # =======================
  # 使用 I18n 的 title 設定
  def page_title_use
    I18n.t "title.#{meta_use_method_name('.')}", { :default => :"title.default" }
  end

  # =======================
  # 沒設定的頁面用這個 & 基礎資料
  def meta_for_default
    {
      og_description: "",
      og_image: "",
    }
  end

end
