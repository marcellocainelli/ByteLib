unit uClienteContato;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TClienteContato = class(TInterfacedObject, iEntidade)
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

{ TClienteContato }

constructor TClienteContato.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CADCLI_HIST_CONTATOS where COD_CLIENTE = :pCod_Cli and data between :pdtini and :pdtfim');

  InicializaDataSource;
end;

destructor TClienteContato.Destroy;
begin
  inherited;
end;

class function TClienteContato.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TClienteContato.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TClienteContato.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('DATA');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TClienteContato.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From CADCLI_HIST_CONTATOS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TClienteContato.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('data')).EditMask:= '!99/99/00;1;_';
end;

function TClienteContato.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
