class CategoryDecorator < Draper::Decorator
  delegate_all

  def path
    "/categories/#{ancestor_categories.join('/')}"
  end

  def music_path
    if children.blank?
      if parent_category.name == 'ミュージックPV'
        # eg) /music/sekai-no-owari
        special_category.present? ? "/music/#{special_category.url}" : "/music/#{id}"
      else
        # eg) /music/akb48-group/akb48
        if special_category.present?
          "/music/#{parent_category.special_category.url}/#{special_category.url}"
        else
          "/music/#{parent_category.id}/#{id}"
        end
      end
    else
      # eg) /music/akb48-group : 子がある場合はindexテンプレートを使う
      special_category.present? ? "/music/#{special_category.url}" : "/music/#{id}"
    end
  end
end
