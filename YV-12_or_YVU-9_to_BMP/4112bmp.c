/*
 * 4112bmp.c - Converts a Mavica .411 file into a .bmp file
 *
 * A .411 file contains 64x48 pixels, where each 4 horizontal
 * pixels is represented by Y1,Y2,Y3,Y3,Cb,Cr. The Cb and Cr
 * values are the same for these 4 pixels.
 *
 * Standard CCIR 601 color conversion is used to convert from
 * Y,Cb,Cr to R,G,B.
*/

#include <stdio.h>
#include <stdlib.h>
#define WIDTH 64
#define HEIGHT 48
unsigned char bmpheader[] = {0x42, 0x4D, 0x36, 0x24, 0x00, 0x00, 0x00, 0x00,
                             0x00, 0x00, 0x36, 0x00, 0x00, 0x00, 0x28, 0x00,
                             0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x30, 0x00,
                             0x00, 0x00, 0x01, 0x00, 0x18, 0x00, 0x00, 0x00,
                             0x00, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
void main(int argc, char **argv)
{
  FILE *inp = NULL;
  FILE *out = NULL;
  char name[512];
  if (argc != 2)
  {
    printf("Usage: 4112bmp mvc-nnnx\n");
    return;
  }
  strcpy(name, argv[1]);
  strcat(name, ".411");
  inp = fopen(name, "rb");
  if (inp)
  {
    strcpy(name, argv[1]);
    strcat(name, ".bmp");
    out = fopen(name, "wb");
    if (out)
    {
      int i, j, k, y[4], cb, cr;
      fwrite(bmpheader, 1, sizeof(bmpheader), out);
      for (k=0; k<HEIGHT; k++)
      {
        fseek(out, sizeof(bmpheader) + (HEIGHT-k-1) * 3 * WIDTH, SEEK_SET);
        for (j=0; j<WIDTH/4; j++)
        {
          y[0] = fgetc(inp);
          y[1] = fgetc(inp);
          y[2] = fgetc(inp);
          y[3] = fgetc(inp);
          cb = fgetc(inp) - 128;
          cr = fgetc(inp) - 128;
          for (i=0; i<4; i++)
          {
            int r, g, b;
            r = y[i] + 1.40200 * cr;
            g = y[i] - 0.34414 * cb - 0.71414 * cr;
            b = y[i] + 1.77200 * cb ;
            if (r < 0) r = 0;
            if (g < 0) g = 0;
            if (b < 0) b = 0;
            if (r > 255) r = 255;
            if (g > 255) g = 255;
            if (b > 255) b = 255;
            fputc(b, out);
            fputc(g, out);
            fputc(r, out);
          }
        }
      }
      fclose(out);
    }
    fclose(inp);
  }
}

