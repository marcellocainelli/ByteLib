unit uCliente;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils, Byte.Lib;

Type
  TCliente = class(TInterfacedObject, iEntidade)
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
  end;

implementation

uses
  uEntidadeBase;

{ TCliente }

constructor TCliente.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From CADCLI Where (1=1) and ');

  InicializaDataSource;
end;

destructor TCliente.Destroy;
begin

  inherited;
end;

class function TCliente.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCliente.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCliente.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
  vNumeroAux: integer;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  {$IFDEF APP}
  if FEntidadeBase.RegraPesquisa = 'Contendo' then
    FEntidadeBase.RegraPesquisa('Containing')
  else if FEntidadeBase.RegraPesquisa = 'In?cio do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  case FEntidadeBase.TipoPesquisa of
    0: begin
        if (not FEntidadeBase.TextoPesquisa.Equals(EmptyStr)) and (TryStrToInt(FEntidadeBase.TextoPesquisa, vNumeroAux)) then
          //busca por c?digo
          vTextoSQL:= vTextoSQL + ' CODIGO = :Parametro'
        else begin
          if FEntidadeBase.RegraPesquisa.Equals('Containing') then
            vTextoSQL:= vTextoSQL + ' Upper(NOME) LIKE' + QuotedStr('%') + ' || Upper(:Parametro) || ' + QuotedStr('%') + ' Order By 2'
          else if FEntidadeBase.RegraPesquisa.Equals('Starting With') then
            vTextoSQL:= vTextoSQL + ' Upper(NOME) LIKE' + ' Upper(:Parametro) || ' + QuotedStr('%') + ' Order By 2';
        end;
       end;
    1: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(ENDERECO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    2: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(BAIRRO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    3: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(CIDADE) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    4: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(FONE) Containing Upper(:Parametro)';
    5: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(RAZAOSOCIAL) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    6: begin
        vTextoSQL:= FEntidadeBase.TextoSql + '(SELECT Retorno FROM spApenasNumeros(CGC) as so_numero) = :Parametro';
        FEntidadeBase.TextoPesquisa(TLib.SomenteNumero(FEntidadeBase.TextoPesquisa));
    end;
    7: vTextoSQL:='Select c.* From CADCLI c Where c.codigo in (SELECT v.cod_cli FROM CARRO v where v.placa Containing :Parametro)';
  end;
  {$ELSE}
  if FEntidadeBase.RegraPesquisa = 'Contendo' then
      FEntidadeBase.RegraPesquisa('Containing')
  else If FEntidadeBase.RegraPesquisa = 'In?cio do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSql + 'CODIGO = :Parametro';
    1: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(NOME) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    2: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(ENDERECO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    3: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(BAIRRO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    4: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(CIDADE) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    5: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(FONE) Containing Upper(:Parametro)';
    6: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(RAZAOSOCIAL) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    7: begin
        vTextoSQL:= FEntidadeBase.TextoSql + '(SELECT Retorno FROM spApenasNumeros(CGC) as so_numero) = :Parametro';
        FEntidadeBase.TextoPesquisa(ApenasNumerosStr(FEntidadeBase.TextoPesquisa));
    end;
    8: vTextoSQL:='Select c.* From CADCLI c Where c.codigo in (SELECT v.cod_cli FROM CARRO v where v.placa Containing :Parametro)';
  end;
  {$ENDIF}
  if FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and OBS <> ' + QuotedStr('INT') + ' Order By 2';
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCliente.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' CODIGO = :Parametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TCliente.ModificaDisplayCampos;
begin

end;

function TCliente.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
