/*
    Student Name:     Michael Maxwell
    Student Number:   101006277
    References:       I did not use any reference material in developing this assignment.
*/

#include "StopLight.h"

bool changeLight(bool &red, bool &yellow, bool &green) {
    if(red + yellow + green == 1) {
        if(red) {
            red = 0;
            green = 1;
        } else if(yellow) {
            yellow = 0;
            red = 1;
        } else {
            green = 0;
            yellow = 1;
        }
        return true;
    }
    return false;
}
