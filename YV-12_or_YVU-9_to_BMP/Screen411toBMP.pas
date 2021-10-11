// D3-D5 411-to-BMP demo program
// efg, April 2000
//
// Thanks to Peter Mora for the sample .411 image to convert.

unit Screen411toBMP;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TForm411toBMP = class(TForm)
    ButtonRead: TButton;
    Image: TImage;
    OpenDialog: TOpenDialog;
    procedure ButtonReadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form411toBMP: TForm411toBMP;

implementation
{$R *.DFM}

USES
  FileCtrl;  // FileExists

// Delphi version of C program at
// http://www.hamrick.com/mavica/4112bmp.txt
FUNCTION Convert411ToBMP(CONST filename:  STRING):  TBitmap;
  TYPE
    TYCbCr =
    RECORD
      Y:   ARRAY[0..3] OF BYTE;
      Cb:  BYTE;
      Cr:  BYTE
    END;

    TRGBTripleArray =  ARRAY[WORD] OF TRGBTriple;
    pRGBTripleArray = ^TRGBTripleArray;

  CONST
     Width  = 64;   // hardwired for 411 files
     Height = 48;

  VAR
    Cb,Cr       :  INTEGER;
    FilePointer :  INTEGER;
    FileStream  :  TFileStream;
    i,j,k       :  INTEGER;
    R,G,B       :  INTEGER;
    Row         :  pRGBTripleArray;
    YCbCr       :  TYCbCr;

BEGIN
  RESULT := TBitmap.Create;
  RESULT.PixelFormat := pf24bit;
  RESULT.Width  := Width;
  RESULT.Height := Height;

  RESULT.Canvas.FillRect(RESULT.Canvas.ClipRect);

  // If file does not exist, a white bitmap will be returned
  IF   FileExists(filename)
  THEN BEGIN
    FileStream := TFileStream.Create(filename, fmOpenRead + fmShareDenyNone);
    TRY
      FilePointer := 0;
      FileStream.Seek(FilePointer, soFromBeginning);

      // 6 bytes in 411 file for each 4 pixels:  Y0 Y1 Y2 Y3 Cb Cr
      FOR j := 0 TO RESULT.Height-1 DO
      BEGIN
        Row  := RESULT.Scanline[j];
        FOR i := 0 TO (RESULT.WIDTH DIV 4)-1 DO
        BEGIN
          FileStream.Read(YCbCr, SizeOf(TYCbCr));
          Cb := YCbCr.Cb - 128;
          Cr := YCbCr.Cr - 128;

          FOR k := 0 TO 3 DO
          BEGIN
            R := YCbCr.Y[k] + Round(1.40200*Cr);
            G := YCbCr.Y[k] - ROUND(0.34414*Cb + 0.71414*Cr);
            B := YCbCr.Y[k] + ROUND(1.77200*Cb);

            IF   R > 255
            THEN R := 255
            ELSE
              IF   R < 0
              THEN R := 0;

            IF   G > 255
            THEN G := 255
            ELSE
              IF   G < 0
              THEN G := 0;

            IF   B > 255
            THEN B := 255
            ELSE
              IF   B < 0
              THEN B := 0;

            row[4*i+k].rgbtRed   := R;
            row[4*i+k].rgbtGreen := G;
            row[4*i+k].rgbtBlue  := B

          END

        END
      END
      
    FINALLY
      FileStream.Free
    END
  END
END {Convert411toBMP};



procedure TForm411toBMP.ButtonReadClick(Sender: TObject);
  VAR
    Bitmap:  TBitmap;
begin
  IF  OpenDialog.Execute
  THEN BEGIN
    Bitmap := Convert411ToBMP(OpenDialog.Filename);
    TRY
      Image.Picture.Graphic := Bitmap
    FINALLY
      Bitmap.Free
    END
  END
end;

procedure TForm411toBMP.FormCreate(Sender: TObject);
begin
  OpenDialog.InitialDir := ExtractFilePath(ParamStr(0))
end;

end.
