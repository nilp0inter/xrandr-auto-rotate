auto-rotate: auto-rotate.c
	gcc $(src) `pkg-config --cflags --libs glib-2.0 gio-2.0 xrandr x11 xi` -o $@
