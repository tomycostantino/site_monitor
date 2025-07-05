class AttachmentsController < ApplicationController
  def download
    blob = ActiveStorage::Blob.find(params[:id])

    if blob.present?
       send_data blob.download, filename: blob.filename.to_s, type: blob.content_type, disposition: "attachment"
    else
      head :not_found
    end
  end
end
