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
    std::function<void( absl::string_view line )> process;

    CHECK_OK( sp.Load( MODEL_FILE ) );

    process = [&]( absl::string_view line ) {
        CHECK_OK( sp.Encode( line, &sps ) );
        for ( auto &sp : sps ) {
            printf( "%s ", sp.c_str( ) );
        }
        printf( "\n" );
    };

    process( "Tested sentence to encode." );
    return 0;
}
