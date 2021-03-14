unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TfmMain = class(TForm)
    HttpClient: TNetHTTPClient;
    pngimage: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    symbols: array of char;
    lastURL: string;
    PNG: TPngImage;
    History: TStringList;
    function GetNewURL: string;
    function GetNextURL: string;
    function GetImageURL(aURL: string): string;
    procedure GetImage(aURL: string);
    procedure RandomImage;
    procedure NextImage;
    procedure SaveImage;
  end;

var
  fmMain: TfmMain;

implementation

uses
  StrUtils;

const
  csURL = 'https://prnt.sc/';

{$R *.dfm}

procedure TfmMain.FormCreate(Sender: TObject);
var
  i: integer;
const
  Sub = '<img class="no-click screenshot-image" src="';
begin
  Randomize;

  SetLength(symbols, 36);
  for i := 0 to 9 do
    symbols[i] := chr(48 + i);
  for i := 0 to 25 do
    symbols[i + 10] := chr(97 + i);

  History := TStringList.Create;

  RandomImage;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(PNG);
  FreeAndNil(History);
end;

procedure TfmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F5) then
    RandomImage
  else if (Key = VK_F2) then
    SaveImage
  else if (Key = VK_RIGHT) then
    NextImage;
end;

function TfmMain.GetNewURL: string;
var
  i: integer;
  add2URL: string;
begin
  for i := 1 to 6 do
    add2URL := add2URL + symbols[Random(High(symbols))];
  result := csURL + add2URL;
  lastURL := add2URL;
  Caption := 'prnt.sc.stalker (' + lastURL + ')';
end;

function TfmMain.GetNextURL: string;
var
  i, ci: integer;
  c: char;
  priorChar: boolean;

  function GetIndex(cc: char): integer;
  var
    j: integer;
  begin
    for j := Low(symbols) to High(symbols) do
      if symbols[j] = cc then
      begin
        result := j;
        exit;
      end;
    j := 0;
  end;

begin
  if lastURL.Length <> 6 then
    Exit;
  i := 6;
  repeat
    c := lastURL[i];
    ci := GetIndex(c);
    priorChar := (ci = High(symbols)); // Последний ли символ в таблице
    if priorChar then
      lastURL[i] := symbols[0]
    else
      lastURL[i] := symbols[ci + 1];
    Dec(i);
  until (i > 1) or (priorChar);
  result := csURL + lastURL;
  Caption := 'prnt.sc.stalker (' + lastURL + ')';
end;

procedure TfmMain.NextImage;
var
  URL: string;
  errors: integer;
begin
  errors := 0;
  repeat
    URL := GetImageURL(GetNextURL);
    Inc(errors);
  until (URL.Length = 0) or (errors < 20);
  if URL.Length > 0 then
  begin
    GetImage(URL);
    History.Add(URL);
  end;
end;

procedure TfmMain.SaveImage;
var
  FolderOUT: string;
begin
  if Assigned(PNG) then
  begin
    FolderOUT := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'OUT');
    ForceDirectories(FolderOUT);
    PNG.SaveToFile(FolderOUT + lastURL + '.png');
  end;
end;

procedure TfmMain.RandomImage;
var
  URL: string;
  errors: integer;
begin
  errors := 0;
  repeat
    URL := GetImageURL(GetNewURL);
    Inc(errors);
  until (URL.Length = 0) or (errors < 20);
  if URL.Length > 0 then
  begin
    GetImage(URL);
    History.Add(URL);
  end;
end;

procedure TfmMain.GetImage(aURL: string);
var
  MS: TMemoryStream;
begin
  MS := TMemoryStream.Create;
  try
    Screen.Cursor := crHourglass;
    try
      HttpClient.Get(aURL, MS);
      MS.Seek(0, soFromBeginning);
      if not Assigned(PNG) then
        PNG := TPngImage.Create;
      PNG.LoadFromStream(MS);
      pngimage.Picture.Assign(PNG);
    except
    end;
  finally
    MS.Free;
    Screen.Cursor := crDefault;
  end;
end;

function TfmMain.GetImageURL(aURL: string): string;
var
  PageText: TStrings;
  posTax, posPNG, URLbegin, URLend: integer;
  CurrentLine: string;
const
  csImageTag = '<img class="no-click screenshot-image" src="';
begin
  result := '';
  PageText := TStringList.Create;
  try
    try
      PageText.LoadFromStream(HttpClient.Get(GetNewURL).ContentStream);
      for CurrentLine in PageText do
      begin
        posTax := Pos(csImageTag, CurrentLine);
        if posTax > 0 then
        begin
          posPNG := PosEx('.png" ', CurrentLine, posTax + 1);
          if posPNG > 0 then
          begin
            URLbegin := posTax + Length(csImageTag);
            URLend := posPNG + 4;
            result := Copy(CurrentLine, URLbegin, URLend - URLbegin);
          end;
        end;
      end;
    except

    end;
  finally
    PageText.Free;
  end;
  //<img class="no-click screenshot-image" src="https://image.prntscr.com/image/9c2748a2e8f54c3ab95c1df1e2591a41.png" crossorigin="anonymous" alt="Lightshot screenshot" id="screenshot-image" image-id="fe4567">
end;

end.
