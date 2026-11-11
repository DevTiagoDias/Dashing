PROJECT_NAME = main
CC           = gcc
SRC_DIR      = src
INC_DIR      = include
BUILD_DIR    = build
RAYLIB_DIR   = libs/raylib/src

# Flags de compilação e caminhos de cabeçalhos (.h)
CFLAGS  = -Wall -Wextra -g -MMD -MP -I$(INC_DIR) -I$(RAYLIB_DIR)
LDFLAGS = -L$(RAYLIB_DIR)

# Encontra arquivos .c em src/ e dentro de subpastas (ex: src/player/player.c)
SRCS = $(wildcard $(SRC_DIR)/*.c) $(wildcard $(SRC_DIR)/*/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))
DEPS = $(OBJS:.o=.d)

ifeq ($(OS),Windows_NT)
	TARGET  = $(PROJECT_NAME).exe
	LDLIBS  = -lraylib -lopengl32 -lgdi32 -lwinmm
	RM      = del /Q /F
	RMDIR   = rmdir /S /Q
	RUN_CMD = $(TARGET)
else
	TARGET  = $(PROJECT_NAME)
	LDLIBS  = -lraylib -lm -lpthread -ldl -lrt -lX11
	RM      = rm -f
	RMDIR   = rm -rf
	RUN_CMD = ./$(TARGET)
endif

.PHONY: all run clean

all: $(TARGET)

# Linkagem final (gera o executável com a Raylib)
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) $(LDFLAGS) $(LDLIBS)

# Compilação individual de cada .c para .o dentro de build/
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
ifeq ($(OS),Windows_NT)
	@if not exist "$(dir $@)" mkdir "$(dir $@)"
else
	@mkdir -p $(dir $@)
endif
	$(CC) $(CFLAGS) -c $< -o $@

# Compila (se houver alterações) e roda o jogo
run: all
	$(RUN_CMD)

# Limpa a pasta build e o executável
clean:
ifeq ($(OS),Windows_NT)
	@if exist "$(BUILD_DIR)" $(RMDIR) "$(BUILD_DIR)"
	@if exist "$(TARGET)" $(RM) "$(TARGET)"
else
	$(RMDIR) $(BUILD_DIR) $(TARGET)
endif

# Monitora alterações nos arquivos .h automaticamente
-include $(DEPS)