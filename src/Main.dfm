object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'prnt.sc.stalker'
  ClientHeight = 682
  ClientWidth = 1173
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PNGImage: TImage
    Left = 0
    Top = 0
    Width = 1173
    Height = 682
    Align = alClient
    Center = True
  end
  object HTTPClient: TNetHTTPClient
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    HandleRedirects = True
    AllowCookies = True
    UserAgent = 'Embarcadero URI Client/1.0'
    SecureProtocols = [SSL2, SSL3, TLS1, TLS11, TLS12]
    Left = 350
    Top = 296
  end
end
