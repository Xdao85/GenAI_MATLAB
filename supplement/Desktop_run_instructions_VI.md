# Chạy lại trong MATLAB desktop

Kết quả lịch sử đã có và được tóm tắt trong README, S2–S4. Muốn chạy mới, sao chép toàn bộ repository sang một thư mục riêng để tránh ghi đè dữ liệu bằng chứng. Đặt MATLAB Current Folder vào bản sao đó, rồi chạy:

```matlab
addpath(fullfile(pwd,'checks'))
run_all_checks
run_gui_reviews
run_gui_repairs
```

Các runner ghi vào `results`; bảo toàn các CSV cũ dưới tên khác trong bản chạy lại trước khi bắt đầu phiên mới. GUI review có thể bỏ qua hàng đã ghi. Quan sát Start, cập nhật hình ít nhất 3 giây, Stop/Pause và Reset; nhập tên người quan sát, 0/1 và mô tả lỗi. Để trống phần chưa kiểm tra. Không dùng -batch thay cho quan sát GUI. Xem REPRODUCING.md và S1_protocol.md.
