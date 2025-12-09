#include <stdio.h>

#define MAX_LINE 1000

long long points[1000][2]; //  2nd dim is x an y

long long my_abs(long long a){
    return a < 0 ? -a : a;
}

long long area_of_rectangle(long long *point1, long long *point2) {
    return 1L * (my_abs(point2[0] - point1[0]) + 1) * (my_abs(point2[1] - point1[1]) + 1);
}

int main() {
    FILE *fptr;

    fptr = fopen("input", "r");

    char line[MAX_LINE];
    int num_points = 0;

    while (fgets(line, MAX_LINE, fptr)) {
        sscanf(line, "%lld,%lld", &points[num_points][0], &points[num_points][1]);
        // printf("%d,%d\n", points[num_points][0], points[num_points][1]);
        num_points++;
    }
    long long max_area = 0;
    for (int i = 0; i < num_points; i++) {
        for (int j = 0; j < num_points; j++) {
            long long area = area_of_rectangle(points[i], points[j]);
            int condition = 1;
            if ((max_area < area) && condition) {
                max_area =  area;
            }
        }
    }
    printf("%lld\n", max_area);
    return 0;
}
