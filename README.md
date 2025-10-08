# LLVM Course Project

MacOS is used for development.

Brew is used to install dependencies.

Make is used for building and running the project.

## LAB 1

Implemented Game of live GUI simulation, source code available at dir [sim_app](sim_app/)

<img src="pics/img.png" alt="demo" style="width:400px; height:auto;">

Run application from root directory with command:

```bash
make run
```

Demo:

![demo1](pics/game-of-live-demo.gif)

Generate IR from sources with:

```bash
make ir
```

## LAB 2

```md
Второе задание (до 8.10 23:59): С помощью инструментирующего Pass собрать (в рантайме) трассу исполненных IR инструкций / трассу использования инструкций (User <- Operand) графического приложения (только для логического модуля - app.c) на -O1/2/3/s (пропуская User, если это phi*). Код Pass выложить в репозиторий.
Провести анализ часто повторяемых паттернов (длина паттерна: 1-5 инструкций). Собранную статистику выложить в репозиторий.

Задание со звёздочкой: при нахождении операнда из инструкции phi, печатать инструкции, используемые в операндах phi.
Пример: запись shl <- phi заменяется на две записи shl <- add и shl <- sub, если этот phi  использует в качестве операндов add и  sub.
```

```bash
make pass
```
