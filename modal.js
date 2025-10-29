Rs(this, 'initModal', project => {
  const modal = document.getElementById('image-modal')
  if (!modal) {
    console.error('Modal element #image-modal not found!')
    return
  }

  const modalImages = modal.querySelector('.modal-images')
  const closeModal = modal.querySelector('.close-modal')
  const closeModalButton = modal.querySelector('.close-modal-button')

  if (!modalImages) {
    console.error('Modal images container not found!')
    return
  }

  // Xóa ảnh cũ
  modalImages.innerHTML = ''

  // Thêm ảnh mới
  project.images.forEach(image => {
    const img = document.createElement('img')
    img.src = image.image
    img.alt = project.project.title
    img.loading = 'lazy'
    modalImages.appendChild(img)
  })

  // Hiện modal
  modal.style.display = 'block'
  document.body.style.overflow = 'hidden' // Ngăn scroll nền

  // Đóng modal
  const close = () => {
    modal.style.display = 'none'
    document.body.style.overflow = ''
  }

  closeModal.onclick = close
  closeModalButton.onclick = close

  // Click ngoài modal
  modal.onclick = event => {
    if (event.target === modal) close()
  }
});

document.addEventListener('DOMContentLoaded', () => {
    const headers = document.querySelectorAll('.loader-header');
    headers.forEach(header => {
        header.addEventListener('click', () => {
            location.reload();
        });
    });
});