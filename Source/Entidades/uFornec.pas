unit uFornec;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TFornec = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TFornec }

constructor TFornec.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select CODIGO, NOME, CGC, IE, ENDERECO, CIDADE, ESTADO, BAIRRO, CEP, FONE, NUMERO, COD_MUNICIPIO, ' +
                         'END_COMPLEMENTO, COD_PAIS, null as INDICE ' +
                         'From FORNEC ');
end;

destructor TFornec.Destroy;
begin
  inherited;
end;

class function TFornec.New: iEntidade;
begin
  Result:= Self.Create;
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
        FEntidadeBase.TextoPesquisa(ApenasNumerosStr(FEntidadeBase.TextoPesquisa));
    end;
  end;
  vTextoSQL:= vTextoSQL + ' and STATUS <> ' + QuotedStr('I') + ' Order By 2';

  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TFornec.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + 'Where CODIGO = :Parametro and STATUS = ''A''');

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TFornec.ModificaDisplayCampos;
begin

end;

end.
