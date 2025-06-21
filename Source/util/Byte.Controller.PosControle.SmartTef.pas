unit Byte.Controller.PosControle.SmartTef;
interface
uses
  System.Classes, System.SysUtils, System.JSon, RESTRequest4D, Byte.Json;
const
  C_MaxConsultas = 30;
  C_TIMEOUT = 30000;
  C_BASE_URL = 'https://api.smarttef.mobi/';
type
  tpCobStatus= (cobAberta, cobCancelada, cobPaga, cobNaoExiste);
  iPosControle = interface
    ['{AC24B481-EE86-4B3E-A6FF-A51D89622D0E}']
    function SubscriptionKey(AValue: String): iPosControle;
    function NumSerialPos(AValue: String): iPosControle;
    function Token(AValue: String): iPosControle;
    function IDCobranca(AValue: String): iPosControle;
    function IDPagamento(AValue: String): iPosControle;
    function QtParcelas(AValue: String): iPosControle;
    function Cpf(AValue: String): iPosControle;
    function Nome(AValue: String): iPosControle;
    function Amount(AValue: Currency): iPosControle;
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
    FSubscriptionKey: string;
    FNumSerialPos, FIDCobranca, FIDPagamento, FQtParcelas, FCpf, FNome, FToken: String;
    FAmount: Currency;
    FCobStatus: tpCobStatus;
    FQtdConsultas: Integer;
    FPaymentId: String;
    constructor Create;
    destructor Destroy; override;
    procedure VerificaPagamento(AValue: string);
  public
    class function New: iPosControle;
    function SubscriptionKey(AValue: String): iPosControle;
    function NumSerialPos(AValue: String): iPosControle;
    function Token(AValue: String): iPosControle;
    function IDCobranca(AValue: String): iPosControle;
    function IDPagamento(AValue: String): iPosControle;
    function QtParcelas(AValue: String): iPosControle;
    function Cpf(AValue: String): iPosControle;
    function Nome(AValue: String): iPosControle;
    function Amount(AValue: Currency): iPosControle;
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
  FNumSerialPos:= '';
  FIDCobranca:= '';
  FIDPagamento:= '';
  FQtParcelas:= '1';
  FCpf:= '';
  FNome:= '';
  FAmount:= 0.00;
  FQtdConsultas:= 0;
end;

destructor TPosControle.Destroy;
begin
  inherited;
end;

function TPosControle.Amount(AValue: Currency): iPosControle;
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

function TPosControle.SubscriptionKey(AValue: String): iPosControle;
begin
  Result:= Self;
  FSubscriptionKey:= AValue;
end;

function TPosControle.Token(AValue: String): iPosControle;
begin
  Result:= Self;
  FToken:= AValue;
end;

function TPosControle.Auth: string;
//var
//  vResp: IResponse;
//  vRetorno: string;
//  vJsonVal: iJsonVal;
begin
  Result:= FToken;
//  Try
//    vResp:= TRequest.New.BaseURL(FBaseURL)
//              .Timeout(C_TIMEOUT)
//              .Resource('v2/auth/token')
//              .ContentType('application/x-www-form-urlencoded')
//              .AddBody('username=' + FUsername + '&password=' + FPassword)
//              .AddHeader('Ocp-Apim-Subscription-Key', FSubscriptionKey)
//              .Post;
//    vJsonVal:= TJsonVal.New(vResp.Content);
//    If vResp.StatusCode = 200 then begin
//      Result:= vJsonVal.GetValueAsString('jwt');
//    end else begin
//      raise Exception.Create('Não autorizado');
//    end;
//  except on E: Exception do
//    raise Exception.Create('Erro ao autenticar: '+ E.Message);
//  end;
end;

function TPosControle.SmartTef: iPosControle;
var
  vResp: IResponse;
  vRetorno, vToken: string;
  vObj, vObjExtras, JSONObjRetorno: TJSONObject;
begin
  Result:= Self;
  Try
    vToken:= Auth;
    vObj:= TJSONObject.Create;
    try
      vObj.AddPair('user_id', TJSONNumber.Create(FNumSerialPos));
      vObj.AddPair('charge_id', FIDCobranca);
      vObj.AddPair('payment_type', FIDPagamento);
      vObj.AddPair('installments', TJSONNumber.Create(FQTParcelas));
      vObj.AddPair('order_type', 'CRD_UNICO');
      vObj.AddPair('value', TJSONNumber.Create(FormatFloat('0.00', FAmount, TFormatSettings.Create('en-US'))));
      if (FCPF <> '') and (FNome <> '') then begin
        vObjExtras := TJSONObject.Create;
        if FCPF <> '' then
          vObjExtras.AddPair('CPF', FCPF);
        if FNome <> '' then
          vObjExtras.AddPair('Nome', FNome);
        vObj.AddPair('extras', vObjExtras);
      end;
      vObj.AddPair('has_details', TJSONBool.Create(false));
      vResp:= TRequest.New.BaseURL(C_BASE_URL)
                .Timeout(C_TIMEOUT)
                .Resource('commands/order/create')
                .ContentType('application/json')
                .AddHeader('Ocp-Apim-Subscription-Key', FSubscriptionKey)
                .TokenBearer(vToken)
                .AddBody(vObj.ToString)
                .Post;
      If vResp.StatusCode = 201 then begin
        FCobStatus:= cobAberta;
        JSONObjRetorno := TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
        try
          JSONObjRetorno.TryGetValue<string>('payment_identifier', FPaymentId);
        finally
          JSONObjRetorno.Free;
        end;
      end else begin
        raise Exception.Create('Erro ao criar cobrança: ' + sLineBreak + vObj.ToString);
      end;
    finally
      vObj.Free;
    end;
  except
    on E: Exception do begin
      FCobStatus:= cobNaoExiste;
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TPosControle.SmartTef_Del: string;
var
  vResp: IResponse;
  vRetorno, vToken: string;
  vObj, vObjExtras: TJSONObject;
  vResponseCode: integer;
begin
  Result:= '';
  Try
    vToken:= Auth;
    vObj:= TJSONObject.Create;
    try
      vObj.AddPair('payment_identifier', FPaymentId);

      vResp:= TRequest.New.BaseURL(C_BASE_URL)
                .Timeout(C_TIMEOUT)
                .Resource('/commands/order/status/cancelar')
                .ContentType('application/json')
                .AddHeader('Ocp-Apim-Subscription-Key', FSubscriptionKey)
                .TokenBearer(vToken)
                .AddBody(vObj.ToString)
                .Post;
      If vResp.StatusCode = 201 then begin
        FCobStatus:= cobCancelada;
      end else
        raise Exception.Create('Erro ao cancelar: ' + vResp.Content);
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
      vObj.AddPair('payment_identifier', FPaymentId);

      vResp:= TRequest.New.BaseURL(C_BASE_URL)
                .Timeout(C_TIMEOUT)
                .Resource('pooling/order/get')
                .ContentType('application/json')
                .AddHeader('Ocp-Apim-Subscription-Key', FSubscriptionKey)
                .TokenBearer(vToken)
                .AddBody(vObj.ToString)
                .Post;
      If vResp.StatusCode = 201 then
        VerificaPagamento(vResp.Content)
      else begin
        FCobStatus:= cobNaoExiste;
        raise Exception.Create(vResp.Content);
      end;
    finally
      vObj.Free;
    end;
  except on E: Exception do
    raise Exception.Create(E.Message);
  end;
end;

procedure TPosControle.VerificaPagamento(AValue: string);
var
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  vPaymentStatus: String;
begin
  JSONArray := TJSONObject.ParseJSONValue(AValue) as TJSONArray;
  try
    if (JSONArray <> nil) and (JSONArray.Count > 0) then begin
      JSONObject := JSONArray.Items[0] as TJSONObject;
      if JSONObject.TryGetValue('payment_status', vPaymentStatus) then begin
        if vPaymentStatus.Contains('CAN') or vPaymentStatus.Contains('REJ') then
          FCobStatus:= cobCancelada
        else if vPaymentStatus.Equals('PDT') or vPaymentStatus.Equals('PROC_PAG') then
          FCobStatus:= cobAberta
        else
          FCobStatus:= cobPaga;

        Exit;
      end else
        raise Exception.Create('Erro ao obter informação de pagamento.');
    end;
  finally
    JSONArray.Free;
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
