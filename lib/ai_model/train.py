import tensorflow as tf
from tensorflow import keras

# 1. Chuẩn bị dữ liệu
train_ds = keras.utils.image_dataset_from_directory(
    'data/train',
    image_size=(224, 224),
    batch_size=32)

val_ds = keras.utils.image_dataset_from_directory(
    'data/val',
    image_size=(224, 224),
    batch_size=32)

# 2. Tạo model
model = keras.Sequential([
    keras.layers.Rescaling(1./255),
    keras.layers.Conv2D(32, 3, activation='relu'),
    keras.layers.MaxPooling2D(),
    keras.layers.Flatten(),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dense(num_classes)
])

# 3. Train model
model.compile(
    optimizer='adam',
    loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=['accuracy'])

model.fit(train_ds, validation_data=val_ds, epochs=10)

# 4. Export sang định dạng Flutter (TFLite)
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
open("model.tflite", "wb").write(tflite_model)