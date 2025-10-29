document.addEventListener('DOMContentLoaded', () => {
  const loaderHeaders = document.querySelectorAll('.loader-header')
  console.log('loaderHeaders', loaderHeaders)
  // Lặp qua từng phần tử và thêm sự kiện 'click'
  loaderHeaders.forEach(loaderHeader => {
    loaderHeader.addEventListener('click', () => {
      location.reload()
    })
  })
})
