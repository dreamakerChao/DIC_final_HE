from PIL import Image
import sys

# 讀取16進制數據
with open(sys.argv[1], "r") as f:
    hex_data = f.read()

# 將16進制數據轉換為像素值列表
pixel_values = [int(hex_code, 16) for hex_code in hex_data.split()]

# 創建新的圖片
new_image = Image.new("L", (660, 440)) # (512,512)

# 將像素值填充到圖片中
new_image.putdata(pixel_values)

# 保存圖片為BMP格式
new_image.save(f"{(sys.argv[1])[:-4]}.bmp")

print("BMP圖片已保存")
