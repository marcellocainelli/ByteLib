unit uFornec;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Byte.Lib;

Type
  TFornec = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
      procedure SelecionaSQLConsulta;
  end;

implementation

uses
  uEntidadeBase;

{ TFornec }

constructor TFornec.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TipoConsulta('Consulta');
  InicializaDataSource;
end;

destructor TFornec.Destroy;
begin
  inherited;
end;

class function TFornec.New: iEntidade;
begin
  Result:= Self.Create;
end;

procedure TFornec.SelecionaSQLConsulta;
begin
  case AnsiIndexStr(FEntidadeBase.TipoConsulta, ['Consulta', 'Cadastro']) of
  0: FEntidadeBase.TextoSQL('Select CODIGO, NOME, CGC, IE, ENDERECO, CIDADE, ESTADO, BAIRRO, CEP, FONE, NUMERO, COD_MUNICIPIO, ' +
                            'END_COMPLEMENTO, COD_PAIS, DTCADASTRO, null as INDICE ' +
                            'From FORNEC ');
  1: FEntidadeBase.TextoSQL('Select * From FORNEC ');
  end;
end;

function TFornec.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TFornec.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  If FEntidadeBase.RegraPesquisa = 'Contendo' then
      FEntidadeBase.RegraPesquisa('Containing')
  else If FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where CODIGO = :mParametro';//busca por código
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where Upper(NOME) ' + FEntidadeBase.RegraPesquisa + ' Upper(:mParametro)';//busca por nome
    2: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where Upper(FANTASIA) ' + FEntidadeBase.RegraPesquisa + ' Upper(:mParametro)';//busca por nome fantasia
    3: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where Upper(ENDERECO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:mParametro)';//busca por endereço
    4: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where Upper(CIDADE) ' + FEntidadeBase.RegraPesquisa + ' Upper(:mParametro)';//buscao por cidade
    5: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where FONE containing :mParametro';//busca por fone
    6: begin
        vTextoSQL:= FEntidadeBase.TextoSQL + ' Where (SELECT Retorno FROM spApenasNumeros(CGC) as so_numero) = :mParametro';
        FEntidadeBase.TextoPesquisa(TLib.SomenteNumero(FEntidadeBase.TextoPesquisa));
    end;
  end;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and STATUS = ''A'' ';
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TFornec.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + 'Where CODIGO = :Parametro and STATUS = ''A''');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TFornec.ModificaDisplayCampos;
begin
  //TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('cgc')).EditMask:= '##.###.###/####-##;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dtcadastro')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('cep')).EditMask:= '00000\-999;1;_';
end;

function TFornec.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
