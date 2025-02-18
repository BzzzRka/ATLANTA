# ATLANTA Fitness App

**ATLANTA** — это мобильное приложение, предназначенное для пользователей, желающих создать свои собственные тренировки и отслеживать прогресс. Делайте каждый день уникальным с ATLANTA!

---

## Основные особенности

- **Создание тренировок**: Пользователи могут создавать свои тренировки, добавлять упражнения и настраивать их продолжительность.
- **Редактирование тренировок**: Изменение информации о тренировках и упражнениях.
- **Уведомления и вибрация**: Уведомления с голосовыми подсказками и вибрациями для плавного переключения между упражнениями.
- **Общий прогресс**: Отслеживание текущего состояния тренировки и прогресса с возможностью возобновления после паузы.
- **Интеграция с Firebase**: Хранение всех тренировок и упражнений в облаке с возможностью редактирования и удаления.
- **Гибкость и настройка**: Множество дефолтных упражнений для выбора при создании тренировки.

---

## Установка

Для того чтобы запустить приложение на своем устройстве, выполните следующие шаги:

1. Клонируйте репозиторий:

    ```bash
    git clone https://github.com/your-username/atlanta_fitness.git
    ```

2. Перейдите в директорию проекта:

    ```bash
    cd atlanta_fitness
    ```

3. Установите все зависимости:

    ```bash
    flutter pub get
    ```

4. Запустите проект:

    ```bash
    flutter run
    ```

P.S. надеюсь вы понимаете, что на этих 4 шагах можно потерять молодость, если вовремя не гуглить ошибки с вашим IDE.

---

## Технологии

- **Flutter** — фреймворк для создания красивых нативных приложений.
- **Firebase** — облачные сервисы для хранения данных и аутентификации.
- **Cloud Firestore** — база данных для хранения информации о тренировках и упражнениях.
- **AudioPlayer** — для проигрывания звуковых эффектов и уведомлений.
- **Vibration** — для добавления вибрации при изменении упражнений.

---

## Структура проекта

- **main.dart** — главный файл приложения, где находится настройка MaterialApp и начальная логика.
- **models.dart** — описание моделей данных (например, тренировки и упражнения).
- **WorkoutScreen.dart** — экран тренировки с таймером, отображением текущего упражнения и прогресса.
- **AddWorkoutScreen.dart** — экран для добавления новой тренировки.
- **EditWorkoutScreen.dart** — экран для редактирования тренировки.

---

## Скриншоты

### Главный экран
![Home Screen](path/to/screenshot1.png)

### Экран тренировки
![Workout Screen](path/to/screenshot2.png)

---

## Разработчики

- **intbizarre** — автор и разработчик, студент на грани вылета, любитель ходить в кино с друзьями.
- **Contact**: st107267@mail.ru

---

### Лицензия

Этот проект лицензирован под [MIT License](LICENSE).

---

Если что-то из описанного выше не понятно или нужно больше информации, не стесняйтесь обращаться!
