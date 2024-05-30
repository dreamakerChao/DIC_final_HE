from PIL import Image

# 開啟圖片
image = Image.open("chickens.bmp")

# 將圖片調整為指定大小
# image = image.resize((512, 512))

# 創建一個txt文件來存儲16進制代碼
with open("pixel_hex_codes.txt", "w") as f:
    # 遍歷每個像素
    for y in range(image.height):
        for x in range(image.width):
            # 獲取像素值（灰階值）
            pixel_value = image.getpixel((x, y))
            # 將灰階值轉換為16進制字符串
            hex_code = format(pixel_value, '02x')
            # 寫入16進制代碼到文件
            f.write(hex_code)
            # 添加空格或換行符號來區分不同的像素
            if x != image.width - 1:
                f.write(" ")
            else:
                f.write("\n")
