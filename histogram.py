from PIL import Image
import numpy as np
import matplotlib.pyplot as plt

# 讀取圖片並轉換為灰度圖
image_path = 'chickens.bmp'  # 替換成你的圖片路徑
image = Image.open(image_path).convert('L')

# 將圖片轉換為NumPy數組
image_array = np.array(image)

# 計算直方圖及其概率分佈
histogram, bin_edges = np.histogram(image_array, bins=256, range=(0, 256), density=True)

# 計算累積分佈函數 (CDF)
cdf = np.cumsum(histogram)

# 定義轉換函數 T(r) = 7 * CDF(r)
def transformation_function(cdf, scale_factor=255):
    return scale_factor * cdf

# 計算所有像素值的轉換結果
s_values = transformation_function(cdf)

# 繪製原始直方圖和CDF
plt.figure(figsize=(12, 6))

# 直方圖
plt.subplot(1, 2, 1)
plt.bar(bin_edges[:-1], histogram, width=1, edgecolor='black', alpha=0.7)
plt.title('Histogram of Pixel Values')
plt.xlabel('Pixel Value')
plt.ylabel('Probability')

# 原始CDF
plt.subplot(1, 2, 2)
plt.plot(bin_edges[:-1], cdf, color='blue')
plt.title('CDF of Original Image')
plt.xlabel('Pixel Value')
plt.ylabel('Cumulative Probability')

plt.tight_layout()
plt.show()

# 顯示每個像素值的分佈概率和轉換後的結果
print("Pixel Value Distributions and Transformed Values:")
for i in range(256):
    print(f"r_{i} = {histogram[i]:.4f}, CDF = {cdf[i]:.4f}, s_{i} = {s_values[i]:.2f}")