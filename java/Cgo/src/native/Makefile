CFLAGS := -I/usr/local/buildtools/java/jdk/include -I/usr/local/buildtools/java/jdk/include/linux -Igo -Iinclude

all: libglue.so

glue.o: Cgo.c
	$(CC) -Wall $(CFLAGS) -fPIC -c -o $@ $<

libglue.so: glue.o
	$(CC) -shared -o $@ $< golib.so

clean:
	rm glue.o libglue.so
