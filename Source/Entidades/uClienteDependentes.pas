unit uClienteDependentes;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TClienteDependentes = class(TInterfacedObject, iEntidade)
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

{ TClienteDependentes }

constructor TClienteDependentes.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CADCLI_DEPENDENTES where COD_CLI = :pCod_Cli');
end;

destructor TClienteDependentes.Destroy;
begin

  inherited;
end;

class function TClienteDependentes.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TClienteDependentes.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TClienteDependentes.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TClienteDependentes.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TClienteDependentes.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('data_nascimento')).EditMask:= '!99/99/00;1;_';
end;

end.
