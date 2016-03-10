require "meta_tags"
require "metalice/selector"

module Metalice

  class << self
    attr_accessor :perform_method
  end

  # =======================

  def metalice_perform(*args)
    meta_hash ||= {}
    meta_hash.merge! use_metalice_meta(args)
    meta_hash.merge! use_metalice_title(args)
    set_meta meta_hash
  end

  # =======================
  def get_hash_opt(get_name_arg, args)
    args.last.class.name == "Hash" ? args.last.fetch(get_name_arg, nil) : nil
  end

  # =======================
  def use_metalice_meta(args)
    # 1. 排除項目
    # TODO

    # 2. 黑名單
    return {} if block_check?

    # 3. 選擇 method
    meta_method_name ||= (get_hash_opt(:metalice_method, args) || meta_select_method_name)
    return send(meta_method_name) if meta_method_name

    {}
  end

  def use_metalice_title(args)
    metalice_title = get_hash_opt(:metalice_title, args)
    case metalice_title.class.name.to_s
    when "FalseClass"
      # 1. false
      title = ""
    when "String"
      # 2. strings
      title = metalice_title
    when "NilClass"
      # 3. nil
      title = i18n_title_use
    when "Hash"
      # 4. hash (auto + args)
      title = i18n_title_use(metalice_title)
    else
      # 5. etc...
      title = i18n_title_use
    end
    { :title => title }
  end

  # =======================
  # 使用 I18n 的 title 設定
  def i18n_title_use(meta_title_hash = {})
    I18n.t "#{i18n_title_prefix}.#{meta_use_method_name('.')}", { :default => :"#{i18n_title_default}" }.merge(meta_title_hash)
  end

  def i18n_title_default
    "#{i18n_title_prefix}.default"
  end

  def i18n_title_prefix
    "metalice.title"
  end

  # =======================
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
  #   1.    Admin::FlagsController#show => meta_for_admin_flags_show
  #   2.    Admin::FlagsController#show => meta_for_admin_flags
  #   3.    Admin::FlagsController#show => meta_for_admin
  #   miss. Admin::FlagsController#show => meta_for_method_miss
  def meta_select_method_name
    Selector.priority MetaliceHelper, meta_use_method_name, { prefix_word: meta_use_method_prefix }
  end

  # =======================
  def block_list
    []
  end

  def block_check?
    block_list.each do |b|
      return true if b =~ meta_use_method_name
    end
    false
  end

  # =======================
  # meta結構
  def organization_meta_makeup
    {
      title: nil,
      description: nil,
      keywords: nil,
      site: nil,
      icon: nil,
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
    meta[:title] ||= data.fetch(:title, "")
    meta[:og] = {}
    meta[:og][:url] ||= data.fetch(:og_url, "")
    meta[:og][:title] ||= data.fetch(:og_title, "")
    meta[:og][:description] ||= data.fetch(:og_description, "")
    meta[:og][:image] ||= data.fetch(:og_image, "")
    self.set_meta_tags organization_meta_makeup.deep_merge(meta)
  end

  # =======================
  # 由 ORM 直接取出
  def metalice_get(ref, meta_hash = {})
    meta_hash.inject({}){ | h, (k, v) |  h[k] = ref.try(v); h }.compact
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
  # 沒設定的頁面用這個 & 基礎資料
  def meta_for_default
    {
      og_description: "",
      og_image: "",
    }
  end

  def meta_for_method_miss
    meta_for_default
  end

end
