unit uPetEspecie;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TPetEspecie = class(TInterfacedObject, iEntidade)
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

{ TPetEspecie }

constructor TPetEspecie.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from PET_ESPECIE');
end;

destructor TPetEspecie.Destroy;
begin
  inherited;
end;

class function TPetEspecie.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPetEspecie.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPetEspecie.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPetEspecie.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TPetEspecie.ModificaDisplayCampos;
begin

end;

end.
