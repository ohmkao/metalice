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

  perform_method "respond_with"
  # or
  # perform_method "render"

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
