asect 0
main: ext
default_handler: ext


dc main, 0
dc default_handler, 0
dc default_handler, 0
dc default_handler, 0
dc default_handler, 0
align 0x80


rsect exc_handlers

default_handler>
    halt
rsect main

main>
    
    halt
end.


