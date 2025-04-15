import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Input, Conv2D, MaxPooling2D, Flatten, Dense
import os

# Đường dẫn đến dataset
dataset_path = 'C:/Users/ADMIN/AndroidStudioProjects/app_doan_nhandien/flower_dataset'  # Cập nhật đường dẫn chính xác

# Tạo data generator
image_size = (150, 150)
batch_size = 32

datagen = ImageDataGenerator(
    rescale=1./255,
    validation_split=0.2
)

train_generator = datagen.flow_from_directory(
    dataset_path,
    target_size=image_size,
    batch_size=batch_size,
    class_mode='categorical',
    subset='training'
)

val_generator = datagen.flow_from_directory(
    dataset_path,
    target_size=image_size,
    batch_size=batch_size,
    class_mode='categorical',
    subset='validation'
)

# Lấy danh sách nhãn (labels) từ train_generator và lưu vào labels.txt
labels = list(train_generator.class_indices.keys())
labels.sort()  # Sắp xếp theo thứ tự bảng chữ cái để khớp với class_indices
with open('labels.txt', 'w', encoding='utf-8') as f:
    for label in labels:
        f.write(f"{label}\n")
print("✅ Đã tạo file labels.txt với các nhãn:", labels)

# Xây dựng model với Input layer để tránh cảnh báo
model = Sequential([
    Input(shape=(150, 150, 3)),
    Conv2D(32, (3, 3), activation='relu'),
    MaxPooling2D(2, 2),
    Conv2D(64, (3, 3), activation='relu'),
    MaxPooling2D(2, 2),
    Flatten(),
    Dense(128, activation='relu'),
    Dense(train_generator.num_classes, activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# Huấn luyện model
model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=10
)

# Lưu mô hình định dạng .h5
model.save('flower_model.h5')
print("✅ Đã lưu mô hình .h5 thành công")

# Convert sang TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Lưu thành file .tflite
with open('flower_model.tflite', 'wb') as f:
    f.write(tflite_model)
print("✅ Đã chuyển thành công model sang .tflite!")

# Copy các file vào thư mục assets của Flutter
flutter_assets_path = 'C:/Users/ADMIN/AndroidStudioProjects/app_doan_nhandien/assets'
os.makedirs(flutter_assets_path, exist_ok=True)
os.replace('flower_model.tflite', os.path.join(flutter_assets_path, 'flower_model.tflite'))
os.replace('labels.txt', os.path.join(flutter_assets_path, 'labels.txt'))
print("✅ Đã di chuyển flower_model.tflite và labels.txt vào thư mục assets của Flutter")