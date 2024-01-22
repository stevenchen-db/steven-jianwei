#include <functional>
#include <string>
#include <vector>

#include "sentencepiece_processor.h"

#define CHECK_OK( s ) _CHECK_OK( s, status##__COUNTER__ )

#define _CHECK_OK( s, status )                                     \
    do {                                                           \
        auto status = ( s );                                       \
        if ( !( status ).ok( ) ) {                                 \
            printf( "unexpected error: %s\n", status.message( ) ); \
            exit( 1 );                                             \
        }                                                          \
    } while ( 0 )

// The Makefile can inject the correct model path.
#ifndef MODEL_FILE
#define MODEL_FILE "shakespeare.model"
#endif

int
main( int argc, char *argv[] )
{
    sentencepiece::SentencePieceProcessor         sp;
    std::vector<std::string>                      sps;
    std::vector<int>                              ids;
    std::function<void( absl::string_view line )> process;

    bool id_mode = false;
    auto input   = "Tested sentence to encode.";

    CHECK_OK( sp.Load( MODEL_FILE ) );

    // Naive argv handling. Must be in order.
    // -- ID model
    if ( argc >= 2 && 0 == strcmp( argv[1], "--id" ) ) {
        argc--;
        argv = argv + 1;

        id_mode = true;
    }

    // -- Input
    if ( argc >= 2 ) {
        argc--;
        argv++;

        input = argv[0];
    }

    // The real logic
    if ( id_mode ) {
        process = [&]( absl::string_view line ) {
            CHECK_OK( sp.Encode( line, &ids ) );
            for ( auto &id : ids ) {
                printf( "%d ", id );
            }
            printf( "\n" );
        };
    } else {
        process = [&]( absl::string_view line ) {
            CHECK_OK( sp.Encode( line, &sps ) );
            for ( auto &sp : sps ) {
                printf( "%s ", sp.c_str( ) );
            }
            printf( "\n" );
        };
    }

    process( input );

    return 0;
}
