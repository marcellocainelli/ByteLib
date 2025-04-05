unit Byte.FreeMClass.XML;

interface

uses
  System.SysUtils, System.Classes, Xml.Reader, Xml.Builder, Xml.Builder.Intf,
  System.StrUtils, uMulticlass, System.IOUtils, System.Types;

type
  IFreeMClassXml = interface
    ['{A408C150-F75E-4B86-B52A-B03C91F4ED74}']
    function Token(AValue: String): IFreeMClassXml;
    function LoadFromFile(const FilePath: string): IFreeMClassXml;
    function LoadFromString(const XMLContent: string): IFreeMClassXml;
    function GenerateNewXML: string;
    function SaveToFile(const FilePath: string): Boolean;
    procedure ProcessFiles(SourcePath, DestPath: string; ASend: Boolean);
  end;

  TFreeMClassXml = class(TInterfacedObject, IFreeMClassXml)
  private
    FXMLContent, FNewXMLContent, FToken: string;
    FXMLBuilder: IXmlBuilder;
    FEmitCNPJ: string;
    FEmitxNome: string;
    FEmitxFant: string;
    FEmitxLgr: string;
    FEmitnro: string;
    FEmitxBairro: string;
    FEmitcMun: string;
    FEmitxMun: string;
    FEmitUF: string;
    FEmitCEP: string;
    FEmitcPais: string;
    FEmitxPais: string;
    FEmitfone: string;
    FEmitIE: string;
    FEmitCRT: string;
    FAutXMLCNPJ: string;

    constructor Create;
    destructor Destroy; override;
    procedure SetXmlNovosDados;
    procedure SetEmitenteCNPJ(const Value: string);
    procedure SetEmitenteNome(const Value: string);
    procedure SetEmitenteFant(const Value: string);
    procedure SetEmitenteLgr(const Value: string);
    procedure SetEmitenteNro(const Value: string);
    procedure SetEmitenteBairro(const Value: string);
    procedure SetEmitenteCMun(const Value: string);
    procedure SetEmitenteMun(const Value: string);
    procedure SetEmitenteUF(const Value: string);
    procedure SetEmitenteCEP(const Value: string);
    procedure SetEmitenteCPais(const Value: string);
    procedure SetEmitenteXPais(const Value: string);
    procedure SetEmitenteFone(const Value: string);
    procedure SetEmitenteIE(const Value: string);
    procedure SetAutXMLCNPJ(const Value: string);

    procedure ReadXml(const AXml: IXmlReader);
    procedure DoPercorreXml(const ANode: Xml.Reader.IXmlNode; AParentNode: Xml.Builder.IXmlNode = nil);
    procedure EnviaXml(const AFile: String);
  public
    class function New: IFreeMClassXml;
    function Token(AValue: String): IFreeMClassXml;
    function LoadFromFile(const FilePath: string): IFreeMClassXml;
    function LoadFromString(const XMLContent: string): IFreeMClassXml;
    function GenerateNewXML: string;
    function SaveToFile(const FilePath: string): Boolean;
    procedure ProcessFiles(SourcePath, DestPath: string; ASend: Boolean);
  end;

implementation

{ TFreeMClassXml }

class function TFreeMClassXml.New: IFreeMClassXml;
begin
  Result:= Self.Create;
end;

constructor TFreeMClassXml.Create;
begin
  FXMLContent:= '';
  FXMLBuilder:= nil;
  SetXmlNovosDados;
end;

destructor TFreeMClassXml.Destroy;
begin

  inherited;
end;

function TFreeMClassXml.Token(AValue: String): IFreeMClassXml;
begin
  Result:= Self;
  FToken:= AValue;
end;

function TFreeMClassXml.GenerateNewXML: string;
begin
  Result:= FNewXMLContent;
end;

function TFreeMClassXml.LoadFromFile(const FilePath: string): IFreeMClassXml;
var
  FileStream: TFileStream;
  StringStream: TStringStream;
begin
  Result := Self;
  if not FileExists(FilePath) then
    Exit;

  try
    FileStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      StringStream := TStringStream.Create('', TEncoding.UTF8);
      try
        StringStream.CopyFrom(FileStream, 0);
        FXMLContent := StringStream.DataString;
        LoadFromString(FXMLContent);
      finally
        StringStream.Free;
      end;
    finally
      FileStream.Free;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro ao carregar arquivo XML: ' + E.Message);
  end;
end;

function TFreeMClassXml.LoadFromString(const XMLContent: string): IFreeMClassXml;
begin
  Result := Self;
  FXMLContent := XMLContent;

  try
    ReadXml(TXMLReader.New.LoadFromString(FXMLContent));
  except
    on E: Exception do begin
      raise Exception.Create('Erro ao analisar XML: ' + E.Message);
    end;
  end;
end;

function TFreeMClassXml.SaveToFile(const FilePath: string): Boolean;
var
  XMLContent: string;
  FileStream: TFileStream;
  StringStream: TStringStream;
begin
  Result := False;
  try
    XMLContent := GenerateNewXML;
    if XMLContent.Trim.IsEmpty then
      Exit;

    FileStream := TFileStream.Create(FilePath, fmCreate);
    try
      StringStream := TStringStream.Create(XMLContent, TEncoding.UTF8);
      try
        FileStream.CopyFrom(StringStream, 0);
        Result := True;
      finally
        StringStream.Free;
      end;
    finally
      FileStream.Free;
    end;
  except
    Result := False;
  end;
end;

procedure TFreeMClassXml.SetAutXMLCNPJ(const Value: string);
begin
  FAutXMLCNPJ:= Value;
end;

procedure TFreeMClassXml.SetEmitenteBairro(const Value: string);
begin
  FEmitxBairro:= Value;
end;

procedure TFreeMClassXml.SetEmitenteCEP(const Value: string);
begin
  FEmitCEP:= Value;
end;

procedure TFreeMClassXml.SetEmitenteCMun(const Value: string);
begin
  FEmitcMun:= Value;
end;

procedure TFreeMClassXml.SetEmitenteCNPJ(const Value: string);
begin
  FEmitCNPJ:= Value;
end;

procedure TFreeMClassXml.SetEmitenteCPais(const Value: string);
begin
  FEmitcPais:= Value;
end;

procedure TFreeMClassXml.SetEmitenteFant(const Value: string);
begin
  FEmitxFant:= Value;
end;

procedure TFreeMClassXml.SetEmitenteFone(const Value: string);
begin
  FEmitfone:= Value;
end;

procedure TFreeMClassXml.SetEmitenteIE(const Value: string);
begin
  FEmitIE:= Value;
end;

procedure TFreeMClassXml.SetEmitenteLgr(const Value: string);
begin
  FEmitxLgr:= Value;
end;

procedure TFreeMClassXml.SetEmitenteMun(const Value: string);
begin
  FEmitxMun:= Value;
end;

procedure TFreeMClassXml.SetEmitenteNome(const Value: string);
begin
  FEmitxNome:= Value;
end;

procedure TFreeMClassXml.SetEmitenteNro(const Value: string);
begin
  FEmitnro:= Value;
end;

procedure TFreeMClassXml.SetEmitenteUF(const Value: string);
begin
  FEmitUF:= Value;
end;

procedure TFreeMClassXml.SetEmitenteXPais(const Value: string);
begin
  FEmitxPais:= Value;
end;

procedure TFreeMClassXml.SetXmlNovosDados;
begin
  SetEmitenteCNPJ('08648367000128');
  SetEmitenteNome('Cainelli Sistemas de Automacao Ltda.');
  SetEmitenteFant('Doutor Byte');
  SetEmitenteLgr('Rua Quinze de Novembro');
  SetEmitenteBairro('Centro');
  SetEmitenteCMun('3550308');  // São Paulo
  SetEmitenteMun('SAO PAULO');
  SetEmitenteUF('SP');
  SetEmitenteCEP('04567000');
  SetEmitenteFone('1145678901');
  SetEmitenteIE('564086930115');
end;

procedure TFreeMClassXml.ReadXml(const AXml: IXmlReader);
begin
  FXMLBuilder:= TXmlBuilder.New.Version('1.0').Encoding('UTF-8');
  DoPercorreXml(AXml.Node);
  FNewXMLContent:= FXMLBuilder.Xml;
end;

procedure TFreeMClassXml.DoPercorreXml(const ANode: Xml.Reader.IXmlNode; AParentNode: Xml.Builder.IXmlNode = nil);
  function GetElement(AName: String; out AValue: Variant): Boolean;
  begin
    Result:= True;
    case AnsiIndexStr(AName, ['CNPJ', 'xNome', 'xFant', 'xLgr', 'xBairro', 'cMun', 'xMun', 'CEP', 'fone', 'IE']) of
      0: AValue:= FEmitCNPJ;
      1: AValue:= FEmitxNome;
      2: AValue:= FEmitxFant;
      3: AValue:= FEmitxLgr;
      4: AValue:= FEmitxBairro;
      5: AValue:= FEmitcMun;
      6: AValue:= FEmitxMun;
      7: AValue:= FEmitCEP;
      8: AValue:= FEmitfone;
      9: AValue:= FEmitIE;
      10: AValue:= FEmitUF;

      else
        Result:= False;
    end;
  end;

var
  LReaderElement: Xml.Reader.IXmlElement;
  LReaderAttribute: Xml.Reader.IXmlAttribute;
  LReaderNode: Xml.Reader.IXmlNode;
  LBuilderNode: Xml.Builder.IXmlNode;
  vElementeValue: Variant;
begin
  // Se estamos processando pela primeira vez (nó raiz)
  if not Assigned(AParentNode) then begin
    // Para o nó raiz, criamos o nó no builder
    LBuilderNode := TXmlNode.New(ANode.Name);

    // Adiciona atributos do nó raiz
    for LReaderAttribute in ANode.Attributes do
      LBuilderNode.AddAttribute(LReaderAttribute.Name, LReaderAttribute.Value);

    FXMLBuilder.AddNode(LBuilderNode);

    // Processa os filhos do nó raiz
    for LReaderNode in ANode.Nodes do
      DoPercorreXml(LReaderNode, LBuilderNode);
  end else begin
    // Para nós filhos
    LBuilderNode := TXmlNode.New(ANode.Name);

    // Adiciona atributos
    for LReaderAttribute in ANode.Attributes do
      LBuilderNode.AddAttribute(LReaderAttribute.Name, LReaderAttribute.Value);

    // Se tiver elementos como <tag>valor</tag>
    for LReaderElement in ANode.Elements do begin
      if GetElement(LReaderElement.Name, vElementeValue) then
        LBuilderNode.AddElement(LReaderElement.Name, vElementeValue)
      else
        LBuilderNode.AddElement(LReaderElement.Name, LReaderElement.Value);
    end;

    // Adiciona ao nó pai
    AParentNode.AddNode(LBuilderNode);

    // Processa filhos deste nó
    for LReaderNode in ANode.Nodes do
      DoPercorreXml(LReaderNode, LBuilderNode);
  end;
end;

procedure TFreeMClassXml.EnviaXml(const AFile: String);
var
  vMulticlass : TMulticlass;
begin
  try
    if FToken.IsEmpty then
      raise Exception.Create('Token não informado.');
    if not FileExists(AFile) then
      raise Exception.Create('Arquivo não encontrado.');
    vMulticlass:= TMulticlass.create;
    try
      vMulticlass.TokenConsultaProd := FToken;
      if not vMulticlass.EnviarArquivo(AFile) then
        raise Exception.Create('Falha no envio do arquivo');
    finally
      vMulticlass.Free;
    end;
  except
    on E:Exception do
      raise Exception.Create('Erro: ' + E.Message);
  end;
end;

procedure TFreeMClassXml.ProcessFiles(SourcePath, DestPath: string; ASend: Boolean);
var
  Files: TStringDynArray;
  FileName: string;
  OutputFileName: string;
  i: Integer;
begin
  if not DirectoryExists(sourcePath) then
    raise Exception.Create('Pasta de origem não existe: ' + sourcePath);

  if not DirectoryExists(destPath) then begin
    if not CreateDir(destPath) then
      raise Exception.Create('Não foi possível criar a pasta de destino: ' + destPath);
  end;

  try
    // Obtém a lista de arquivos da pasta
    Files := TDirectory.GetFiles(sourcePath);

    for i := 0 to Length(Files) - 1 do begin
      FileName := ExtractFileName(Files[i]);
      OutputFileName := destPath + PathDelim + FileName;

      try
        // Carrega o conteúdo do arquivo
        LoadFromFile(sourcePath + PathDelim + FileName);

        // Salva o arquivo com novo nome
        SaveToFile(OutputFileName);
        if ASend then
          EnviaXml(OutputFileName);
      except

      end;
    end;

  except

  end;
end;

end.
