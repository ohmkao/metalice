# === GUIDES: MetaTagHelper ===
# USE:
#   include MetaTagHelper
# EX:
#   包含 namespace 判斷，自動對應
#   1: PostsController#press => meta_for_posts_press
#   2: Admin::FlagsController#show => meta_for_admin_flags_show
# EDITOR:
#   @xxx by controller
#   add:
#     def meta_for_admin_flags_show
#       @xxx
#       ...
#     end
# ===

module MetaliceHelper
  include Metalice

  # =======================
  # TODO
  # def render(*args)
  #   super
  # end

  def respond_with(*args)
    metalice_perform(args) if Metalice.perform_method.to_s == __method__ || Metalice.perform_method.nil?
    super
  end

  # =======================
  def block_list
    [
      /^admin/,
      /^api/,
    ]
  end

  # =======================
  # 沒設定的頁面用這個 & 基礎資料
  def meta_for_default
    {
      og_description: "rails-abyss",
      og_image: "",
    }
  end

  # =======================
  # 對應 method
  # DEV: editor
  def meta_for_base_index
    meta_for_default
  end

end
