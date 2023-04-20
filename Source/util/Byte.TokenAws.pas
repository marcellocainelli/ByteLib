unit Byte.TokenAws;

interface

uses
  System.Classes, System.SysUtils, System.JSon, RESTRequest4D,
  Byte.Json;

type
  iTokenAws = interface
    ['{AC24B481-EE86-4B3E-A6FF-A51D89622D0E}']
    function BaseURL(AValue: String): iTokenAws;
    function GetJWT: string;
  end;

  TTokenAws = class(TInterfacedObject, iTokenAws)
  private
    FBaseURL: string;
  public
    class function New: iTokenAws;
    constructor Create;
    destructor Destroy; override;
    function BaseURL(AValue: String): iTokenAws;
    function GetJWT: string;
  end;

implementation

{ TTokenAws }

class function TTokenAws.New: iTokenAws;
begin
  Result:= Self.Create;
end;

constructor TTokenAws.Create;
begin
  FBaseURL:= 'https://byteclientes-api.byteempresa.com.br/';
end;

destructor TTokenAws.Destroy;
begin

  inherited;
end;

function TTokenAws.GetJWT: string;
var
  vResp: IResponse;
  JObjeto : TJSONObject;
  JValue: TJSONValue;
  vRetorno: string;
  vJsonVal: iJsonVal;
  vJsonObj: iJsonObj;
begin
  vJsonObj:= TJsonObj.New;
  vJsonObj.AddPair('USUARIO', 'byteclientesapi');
  vJsonObj.AddPair('SENHA', 'QLV]66BZQjv.1AZ;e+93');
  Try
    vResp:= TRequest.New.BaseURL(FBaseURL)
              .Timeout(5000)
              .Resource('JWTAuth')
              .ContentType('application/json')
              .AcceptEncoding('UTF-8')
              .AddBody(vJsonObj.ToString)
              .Post;
    If vResp.StatusCode = 200 then
      Result:= vResp.Content
    else begin
      vJsonVal:= TJsonVal.New(vResp.Content);
      vRetorno:= vJsonVal.GetValueAsString('error');
      raise Exception.Create(vRetorno);
    end;
  except on E: Exception do
    raise Exception.Create('Erro ao autenticar com site doutor byte: '+ E.Message);
  end;
end;

function TTokenAws.BaseURL(AValue: String): iTokenAws;
begin
  Result:= Self;
  FBaseURL:= AValue;
end;

end.
