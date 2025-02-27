unit Byte.Controller.PosControle;

interface

uses
  System.Classes, System.SysUtils, System.JSon, RESTRequest4D, Byte.Json;

const
  C_MaxConsultas = 30;

type
  tpCobStatus= (cobAberta, cobCancelada, cobPaga, cobNaoExiste);

  iPosControle = interface
    ['{AC24B481-EE86-4B3E-A6FF-A51D89622D0E}']
    function BaseURL(AValue: String): iPosControle;
    function Username(AValue: String): iPosControle;
    function Password(AValue: String): iPosControle;
    function SubscriptionKey(AValue: String): iPosControle;
    function NumSerialPos(AValue: String): iPosControle;
    function IDCobranca(AValue: String): iPosControle;
    function IDPagamento(AValue: String): iPosControle;
    function QtParcelas(AValue: String): iPosControle;
    function Cpf(AValue: String): iPosControle;
    function Nome(AValue: String): iPosControle;
    function Amount(AValue: String): iPosControle;
    function CobStatus: tpCobStatus;
    function Auth: string;
    function SmartTef: iPosControle; //nova venda
    function SmartTef_Del: string; //exclui venda
    function GetStatus: iPosControle;
    function QtdConsultas: integer; overload;
    function QtdMaxConsultas: integer;

    procedure QtdConsultas(Value: integer); overload;
  end;

  TPosControle = class(TInterfacedObject, iPosControle)
  private
    FBaseURL, FSubscriptionKey, FUsername, FPassword: string;
    FNumSerialPos, FIDCobranca, FIDPagamento, FQtParcelas, FCpf, FNome, FAmount: String;
    FCobStatus: tpCobStatus;
    FQtdConsultas: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure VerificaPagamento(AValue: string);
  public
    class function New: iPosControle;
    function BaseURL(AValue: String): iPosControle;
    function Username(AValue: String): iPosControle;
    function Password(AValue: String): iPosControle;
    function SubscriptionKey(AValue: String): iPosControle;
    function NumSerialPos(AValue: String): iPosControle;
    function IDCobranca(AValue: String): iPosControle;
    function IDPagamento(AValue: String): iPosControle;
    function QtParcelas(AValue: String): iPosControle;
    function Cpf(AValue: String): iPosControle;
    function Nome(AValue: String): iPosControle;
    function Amount(AValue: String): iPosControle;
    function CobStatus: tpCobStatus;
    function Auth: string;
    function SmartTef: iPosControle;
    function SmartTef_Del: string;
    function GetStatus: iPosControle;
    function QtdConsultas: integer; overload;
    function QtdMaxConsultas: integer;

    procedure QtdConsultas(Value: integer); overload;
  end;

implementation

{ TTokenAws }

class function TPosControle.New: iPosControle;
begin
  Result:= Self.Create;
end;

constructor TPosControle.Create;
begin
  FBaseURL:= 'https://api.poscontrole.com.br/';
  FNumSerialPos:= '';
  FIDCobranca:= '';
  FIDPagamento:= '';
  FQtParcelas:= '1';
  FCpf:= '';
  FNome:= '';
  FAmount:= '0.00';
  FQtdConsultas:= 0;
end;

destructor TPosControle.Destroy;
begin

  inherited;
end;

function TPosControle.Amount(AValue: String): iPosControle;
begin
  Result:= Self;
  FAmount:= AValue;
end;

function TPosControle.CobStatus: tpCobStatus;
begin
  Result:= FCobStatus;
end;

function TPosControle.Cpf(AValue: String): iPosControle;
begin
  Result:= Self;
  FCpf:= AValue;
end;

function TPosControle.IDCobranca(AValue: String): iPosControle;
begin
  Result:= Self;
  FIDCobranca:= AValue;
end;

function TPosControle.IDPagamento(AValue: String): iPosControle;
begin
  Result:= Self;
  FIDPagamento:= AValue;
end;

function TPosControle.Nome(AValue: String): iPosControle;
begin
  Result:= Self;
  FNome:= AValue;
end;

function TPosControle.NumSerialPos(AValue: String): iPosControle;
begin
  Result:= Self;
  FNumSerialPos:= AValue;
end;

function TPosControle.QtParcelas(AValue: String): iPosControle;
begin
  Result:= Self;
  FQtParcelas:= AValue;
end;

function TPosControle.Password(AValue: String): iPosControle;
begin
  Result:= Self;
  FPassword:= AValue;
end;

function TPosControle.SubscriptionKey(AValue: String): iPosControle;
begin
  Result:= Self;
  FSubscriptionKey:= AValue;
end;

function TPosControle.Username(AValue: String): iPosControle;
begin
  Result:= Self;
  FUsername:= AValue;
end;

function TPosControle.BaseURL(AValue: String): iPosControle;
begin
  Result:= Self;
  FBaseURL:= AValue;
end;

function TPosControle.Auth: string;
var
  vResp: IResponse;
  vRetorno: string;
  vJsonVal: iJsonVal;
begin
  Try
    vResp:= TRequest.New.BaseURL(FBaseURL)
              .Timeout(10000)
              .Resource('v2/auth/token')
              .ContentType('application/x-www-form-urlencoded')
              .AddBody('username=' + FUsername + '&password=' + FPassword)
              .AddHeader('Ocp-Apim-Subscription-Key', FSubscriptionKey)
              .Post;

    vJsonVal:= TJsonVal.New(vResp.Content);
    If vResp.StatusCode = 200 then begin
      Result:= vJsonVal.GetValueAsString('jwt');
    end else begin
      raise Exception.Create('Não autorizado');
    end;
  except on E: Exception do
    raise Exception.Create('Erro ao autenticar: '+ E.Message);
  end;
end;

function TPosControle.SmartTef: iPosControle;
var
  vResp: IResponse;
  vRetorno, vToken: string;
  vObj, vObjExtras: TJSONObject;
begin
  Result:= Self;
  Try
    vToken:= Auth;

    vObj:= TJSONObject.Create;
    try
      vObj.AddPair('NumSerialPOS', FNumSerialPOS);
      vObj.AddPair('IDCobranca', FIDCobranca);
      vObj.AddPair('IDPagamento', FIDPagamento);
      vObj.AddPair('QTParcelas', FQTParcelas);
      vObj.AddPair('Amount', FAmount);

      if (FCPF <> '') and (FNome <> '') then begin
        vObjExtras := TJSONObject.Create;
        if FCPF <> '' then
          vObjExtras.AddPair('CPF', FCPF);
        if FNome <> '' then
          vObjExtras.AddPair('Nome', FNome);

        vObj.AddPair('Extras', vObjExtras);
      end;

      vResp:= TRequest.New.BaseURL(FBaseURL)
                .Timeout(10000)
                .Resource('v3/smart-tef/newItem')
                .ContentType('application/json')
                .AddHeader('Ocp-Apim-Subscription-Key', FSubscriptionKey)
                .TokenBearer(vToken)
                .AddBody(vObj.ToString)
                .Post;

      If vResp.StatusCode = 200 then begin
        FCobStatus:= cobAberta;
      end else begin
        raise Exception.Create('Não autorizado');
      end;

    finally
      vObj.Free;
    end;
  except on E: Exception do
    raise Exception.Create(E.Message);
  end;
end;

function TPosControle.SmartTef_Del: string;
var
  vResp: IResponse;
  vRetorno, vToken: string;
  vObj, vObjExtras: TJSONObject;
begin
  Result:= '';
  Try
    vToken:= Auth;

    vObj:= TJSONObject.Create;
    try
      vObj.AddPair('NumSerialPOS', FNumSerialPOS);
      vObj.AddPair('IDCobranca', FIDCobranca);
      vObj.AddPair('IDPagamento', FIDPagamento);
      vObj.AddPair('QTParcelas', FQTParcelas);
      vObj.AddPair('Amount', FAmount);
      vObj.AddPair('action', 'delete');

      if (FCPF <> '') and (FNome <> '') then begin
        vObjExtras := TJSONObject.Create;
        if FCPF <> '' then
          vObjExtras.AddPair('CPF', FCPF);
        if FNome <> '' then
          vObjExtras.AddPair('Nome', FNome);

        vObj.AddPair('Extras', vObjExtras);
      end;

      vResp:= TRequest.New.BaseURL(FBaseURL)
                .Timeout(10000)
                .Resource('v3/smart-tef/newItem')
                .ContentType('application/json')
                .AddHeader('Ocp-Apim-Subscription-Key', FSubscriptionKey)
                .TokenBearer(vToken)
                .AddBody(vObj.ToString)
                .Post;

      If vResp.StatusCode = 200 then begin
        Result:= 'Cobrança cancelada com sucesso!';
        FCobStatus:= cobCancelada;
      end else
        raise Exception.Create(vResp.Content);

    finally
      vObj.Free;
    end;
  except on E: Exception do
    raise Exception.Create(E.Message);
  end;
end;

function TPosControle.GetStatus: iPosControle;
var
  vResp: IResponse;
  vRetorno, vToken: string;
  vObj, vObjExtras: TJSONObject;
begin
  Result:= Self;

  Try
    vToken:= Auth;

    vObj:= TJSONObject.Create;
    try
      vObj.AddPair('IDCobranca', FIDCobranca);

      vResp:= TRequest.New.BaseURL(FBaseURL)
                .Timeout(10000)
                .Resource('v3/smart-tef/get-status')
                .ContentType('application/json')
                .AddHeader('Ocp-Apim-Subscription-Key', FSubscriptionKey)
                .TokenBearer(vToken)
                .AddBody(vObj.ToString)
                .Post;

      If vResp.StatusCode = 200 then
        VerificaPagamento(vResp.Content)
      else
        raise Exception.Create(vResp.Content);

    finally
      vObj.Free;
    end;
  except on E: Exception do
    raise Exception.Create(E.Message);
  end;
end;

procedure TPosControle.VerificaPagamento(AValue: string);
var
  JsonObject, DataObject, DataObjectResponse: TJSONObject;
  DataValue, DataValueResponse: TJSONValue;
  Pagamentos: string;
  ResponseCode: string;
begin
  Pagamentos := ''; // Inicializa com string vazia
  JsonObject := nil;
  JsonObject := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
  try
    // Verifica se JsonObject foi criado corretamente
    if Assigned(JsonObject) then begin
      // Verifica se existe a cobranca
      ResponseCode := JsonObject.GetValue<String>('responseCode');
      if ResponseCode = '401.05' then begin
        FCobStatus:= cobNaoExiste;
        Exit;
      end;

      // Acessa o objeto "data"
      DataValue := JsonObject.GetValue('data');
      if Assigned(DataValue) and (DataValue is TJSONObject) then begin
        DataObject := DataValue as TJSONObject;
        // Captura o valor de "Pagamentos" se ele estiver presente e não for null
        if DataObject.TryGetValue<string>('Pagamentos', Pagamentos) then begin
          if Pagamentos.IsEmpty then
            FCobStatus:= cobAberta
          else
            FCobStatus:= cobPaga;
        end;
      end;
    end;
  finally
    JsonObject.Free;
  end;
end;

function TPosControle.QtdConsultas: integer;
begin
  Result:= FQtdConsultas;
end;

procedure TPosControle.QtdConsultas(Value: integer);
begin
  FQtdConsultas:= Value;
end;

function TPosControle.QtdMaxConsultas: integer;
begin
  Result:= C_MaxConsultas;
end;

end.
