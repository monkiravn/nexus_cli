#!/bin/bash
# --- Thiết lập Swap ---
SWAP_SIZE=12G
SWAP_FILE=/swapfile

# Tạo file swap (dùng fallocate hoặc dd nếu fallocate không thành công)
sudo fallocate -l $SWAP_SIZE $SWAP_FILE || sudo dd if=/dev/zero of=$SWAP_FILE bs=1M count=12288

# Cấp quyền truy cập an toàn cho file swap
sudo chmod 600 $SWAP_FILE

# Định dạng file swap và kích hoạt nó
sudo mkswap $SWAP_FILE
sudo swapon $SWAP_FILE

# Thêm swap vào /etc/fstab nếu chưa có
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
fi

# Điều chỉnh swappiness cho hệ thống
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swap.conf
sudo sysctl -p /etc/sysctl.d/99-swap.conf

echo "Swap setup completed. Checking status..."
free -h

# --- Cập nhật và nâng cấp hệ thống ---
sudo apt update && sudo apt upgrade -y

# --- Cài đặt các gói cần thiết ---
sudo apt install -y build-essential pkg-config libssl-dev git-all protobuf-compiler

# --- Cài đặt Rust (rustup) và thêm target cho riscv ---
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Sau khi cài đặt rustup, hãy đảm bảo PATH đã được cập nhật
export PATH="$HOME/.cargo/bin:$PATH"

# Lệnh dưới có thể không cần nếu rustup đã được cài đặt qua script trên
sudo apt install -y rustup

# Thêm target riscv cho rustup
rustup target add riscv32i-unknown-none-elf

# --- Cài đặt Nexus CLI ---
curl https://cli.nexus.xyz/ | sh
