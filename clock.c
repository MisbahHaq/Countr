#include <stdio.h>
#include <time.h>

void fill_time(char *, int);

int main()
{
    char time[50];

    int format;
    printf("\nChoose the Time Format: \n");
    printf("\n1. 24 Hour Format");
    printf("\n2. 12 Hour Format (default)\n");
    printf("\nMake a Choice:(1/2) ");
    scanf("%d", &format);
    fill_time(time, format);

    printf("\nCurrent Time: %s", time);
    return 0;
}

void fill_time(char *buffer, int format)
{
    time_t raw_time;
    struct tm *current_time;

    time(&raw_time);
    current_time = localtime(&raw_time);
    if (format == 1)
    {
        strftime(buffer, 50, "%H:%M:%S", current_time);
    }
    else
    {
        strftime(buffer, 50, "%I:%M:%S %p", current_time);
    }
}
