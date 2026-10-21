unit Byte.Controller.Ailog.Ciot;

// Integração AILOG - CIOT (API de Recibo) - Manual de Integração v1.0 (WebServices REST)
// Gera o comprovante digital (recibo) de um registro CIOT. A API devolve o PDF em Base64.
//
// Exemplo de uso:
//   vCiot:= TAilogCiot.New
//             .Homologacao(False)
//             .ChaveAcesso('chave-fornecida-pela-ailog')
//             .Protocolo('CIOT20250001')           // e/ou IdOperacaoTransporte('123456')
//             .ConsultaRecibo;
//   if vCiot.Sucesso then
//     vCiot.ReciboToFile('C:\Temp\recibo_ciot.pdf')
//   else
//     ShowMessage(vCiot.Mensagem);

interface

uses
  System.Classes, System.SysUtils, Soap.EncdDecd, RESTRequest4D, Byte.Json;

const
  C_TIMEOUT         = 60000;
  C_URL_PRODUCAO    = 'https://way.webrouter.com.br/crud';
  C_URL_HOMOLOGACAO = 'https://way-hml.webrouter.com.br/crud';
  C_RESOURCE_RECIBO = 'crud/portal/ciot/v3/recibo';

type
  iAilogCiot = interface
  ['{C84245D3-D706-4911-AD0A-47AAF2E13105}']
    function Sucesso: Boolean;
    function Mensagem: String;
    function StatusCode: Integer;
    function Homologacao(AValue: Boolean): iAilogCiot;
    function BaseURL(AValue: String): iAilogCiot;
    function ChaveAcesso(AValue: String): iAilogCiot;
    function IdOperacaoTransporte(AValue: String): iAilogCiot;
    function Protocolo(AValue: String): iAilogCiot;
    function ConsultaRecibo: iAilogCiot;
    function ReciboBase64: String;
    function ReciboToStream(AStream: TStream): iAilogCiot;
    function ReciboToFile(const AFileName: String): iAilogCiot;
  end;

  TAilogCiot = class(TInterfacedObject, iAilogCiot)
    private
      FSucesso, FHomologacao: Boolean;
      FMsg, FBaseURL, FChaveAcesso, FIdOperacaoTransporte, FProtocolo, FReciboBase64: String;
      FStatusCode: Integer;
      constructor Create;
      destructor Destroy; override;
      function GetBaseURL: String;
      function MontaReqBody: String;
      function LimpaBase64(const AValue: String): String;
      procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
    public
      class function New: iAilogCiot;
      function Sucesso: Boolean;
      function Mensagem: String;
      function StatusCode: Integer;
      function Homologacao(AValue: Boolean): iAilogCiot;
      function BaseURL(AValue: String): iAilogCiot;
      function ChaveAcesso(AValue: String): iAilogCiot;
      function IdOperacaoTransporte(AValue: String): iAilogCiot;
      function Protocolo(AValue: String): iAilogCiot;
      function ConsultaRecibo: iAilogCiot;
      function ReciboBase64: String;
      function ReciboToStream(AStream: TStream): iAilogCiot;
      function ReciboToFile(const AFileName: String): iAilogCiot;
  end;

implementation

{ TAilogCiot }

class function TAilogCiot.New: iAilogCiot;
begin
  Result:= Self.Create;
end;

constructor TAilogCiot.Create;
begin
  FHomologacao:= False;
  FSucesso:= False;
  FStatusCode:= 0;
end;

destructor TAilogCiot.Destroy;
begin

  inherited;
end;

procedure TAilogCiot.SetReqResult(ASucesso: Boolean; AMensagem: String);
begin
  FSucesso:= ASucesso;
  FMsg:= AMensagem;
end;

function TAilogCiot.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;

function TAilogCiot.Mensagem: String;
begin
  Result:= FMsg;
end;

function TAilogCiot.StatusCode: Integer;
begin
  Result:= FStatusCode;
end;

function TAilogCiot.Homologacao(AValue: Boolean): iAilogCiot;
begin
  Result:= Self;
  FHomologacao:= AValue;
end;

function TAilogCiot.BaseURL(AValue: String): iAilogCiot;
begin
  Result:= Self;
  FBaseURL:= AValue;
end;

function TAilogCiot.ChaveAcesso(AValue: String): iAilogCiot;
begin
  Result:= Self;
  FChaveAcesso:= AValue;
end;

function TAilogCiot.IdOperacaoTransporte(AValue: String): iAilogCiot;
begin
  Result:= Self;
  FIdOperacaoTransporte:= AValue;
end;

function TAilogCiot.Protocolo(AValue: String): iAilogCiot;
begin
  Result:= Self;
  FProtocolo:= AValue;
end;

function TAilogCiot.ReciboBase64: String;
begin
  Result:= FReciboBase64;
end;

//BaseURL informada manualmente tem prioridade; senão usa homologação/produção
function TAilogCiot.GetBaseURL: String;
begin
  if not FBaseURL.Trim.IsEmpty then
    Result:= FBaseURL.Trim
  else if FHomologacao then
    Result:= C_URL_HOMOLOGACAO
  else
    Result:= C_URL_PRODUCAO;
end;

//Envia somente os campos informados (o manual exige ao menos um deles)
function TAilogCiot.MontaReqBody: String;
var
  vJsonObj: iJsonObj;
begin
  vJsonObj:= TJsonObj.New;
  if not FIdOperacaoTransporte.Trim.IsEmpty then
    vJsonObj.AddPair('idOperacaoTransporte', FIdOperacaoTransporte.Trim);
  if not FProtocolo.Trim.IsEmpty then
    vJsonObj.AddPair('protocolo', FProtocolo.Trim);
  Result:= vJsonObj.ToString;
end;

//O retorno é uma string Base64; remove aspas, quebras de linha e escapes caso venha como JSON string
function TAilogCiot.LimpaBase64(const AValue: String): String;
begin
  Result:= AValue.Trim;
  if Result.StartsWith('"') and Result.EndsWith('"') and (Length(Result) >= 2) then
    Result:= Copy(Result, 2, Length(Result) - 2);
  Result:= Result.Replace('\/', '/').Replace('\r', '').Replace('\n', '');
  Result:= Result.Replace(#13, '').Replace(#10, '').Replace(' ', '');
end;

function TAilogCiot.ConsultaRecibo: iAilogCiot;
var
  vResp: IResponse;
begin
  Result:= Self;
  FReciboBase64:= '';
  FStatusCode:= 0;

  if FChaveAcesso.Trim.IsEmpty then begin
    SetReqResult(False, 'A chave de acesso não foi informada!');
    Exit;
  end;

  if FIdOperacaoTransporte.Trim.IsEmpty and FProtocolo.Trim.IsEmpty then begin
    SetReqResult(False, 'Informe o protocolo e/ou o ID da operação de transporte!');
    Exit;
  end;

  try
    vResp:= TRequest.New.BaseURL(GetBaseURL)
              .Timeout(C_TIMEOUT)
              .Resource(C_RESOURCE_RECIBO)
              .ContentType('application/json')
              .AcceptEncoding('UTF-8')
              .AddHeader('chaveAcesso', FChaveAcesso.Trim)
              .AddBody(MontaReqBody)
              .Post;

    FStatusCode:= vResp.StatusCode;
    case vResp.StatusCode of
      200: begin
        FReciboBase64:= LimpaBase64(vResp.Content);
        if FReciboBase64.IsEmpty then
          raise Exception.Create('A API retornou o recibo vazio.');
        SetReqResult(True, 'Recibo gerado com sucesso');
      end;
      403: raise Exception.Create('Chave de acesso inválida ou sem licença de uso ativa (HTTP 403).');
      500: raise Exception.Create('Erro na geração do PDF: ' + vResp.Content);
    else
      raise Exception.Create('HTTP ' + IntToStr(vResp.StatusCode) + ': ' + vResp.Content);
    end;
  except
    on E: Exception do begin
      FReciboBase64:= '';
      SetReqResult(False, 'Erro:' + sLineBreak + E.Message);
    end;
  end;
end;

//Decodifica o Base64 do último ConsultaRecibo e grava o PDF no stream informado
function TAilogCiot.ReciboToStream(AStream: TStream): iAilogCiot;
var
  vBytes: TBytes;
begin
  Result:= Self;
  if FReciboBase64.IsEmpty then begin
    SetReqResult(False, 'Nenhum recibo disponível. Execute ConsultaRecibo antes!');
    Exit;
  end;

  if not Assigned(AStream) then begin
    SetReqResult(False, 'O stream de destino não foi informado!');
    Exit;
  end;

  try
    vBytes:= DecodeBase64(AnsiString(FReciboBase64));
    //Todo PDF válido começa com "%PDF"
    if (Length(vBytes) < 4) or (vBytes[0] <> $25) or (vBytes[1] <> $50) or
       (vBytes[2] <> $44) or (vBytes[3] <> $46) then
      raise Exception.Create('O conteúdo retornado não é um PDF válido.');
    AStream.WriteBuffer(vBytes[0], Length(vBytes));
    AStream.Position:= 0;
    SetReqResult(True, 'Recibo convertido com sucesso');
  except
    on E: Exception do
      SetReqResult(False, 'Erro:' + sLineBreak + E.Message);
  end;
end;

function TAilogCiot.ReciboToFile(const AFileName: String): iAilogCiot;
var
  vStream: TMemoryStream;
  vDir: String;
begin
  Result:= Self;
  if AFileName.Trim.IsEmpty then begin
    SetReqResult(False, 'O nome do arquivo não foi informado!');
    Exit;
  end;

  vStream:= TMemoryStream.Create;
  try
    ReciboToStream(vStream);
    if not FSucesso then
      Exit;
    try
      vDir:= ExtractFilePath(AFileName);
      if (vDir <> '') and (not DirectoryExists(vDir)) then
        ForceDirectories(vDir);
      vStream.SaveToFile(AFileName);
      SetReqResult(True, 'Recibo salvo em: ' + AFileName);
    except
      on E: Exception do
        SetReqResult(False, 'Erro ao salvar o recibo:' + sLineBreak + E.Message);
    end;
  finally
    vStream.Free;
  end;
end;

end.
