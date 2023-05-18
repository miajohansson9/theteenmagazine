class Ckeditor::Picture < Ckeditor::Asset
  # for validation, see https://github.com/igorkasyanchuk/active_storage_validations

  def url_content
    rails_representation_url(storage_data.variant(resize_to_fit: [560, nil]).processed, only_path: true)
  end

  def url_thumb
    rails_representation_url(storage_data.variant(resize_to_fit: [118, 100]).processed, only_path: true)
  end
end
