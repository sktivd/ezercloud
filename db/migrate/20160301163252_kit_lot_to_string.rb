class KitLotToString < ActiveRecord::Migration

  def up
    change_table :frends do |t|
      t.change :kit, :string
      t.change :lot, :string
    end
    
    change_table :assay_kits do |t|
      t.change :kit, :string
    end
    
    change_table :reagents do |t|
      t.change :number, :string
    end
  end
  
  def down
    connection.execute(%q{
      alter table frends
      alter column kit
      type integer using cast (kit as integer)
    })
    connection.execute(%q{
      alter table frends
      alter column lot
      type integer using cast (lot as integer)
    })
    connection.execute(%q{
      alter table assay_kits
      alter column kit
      type integer using cast (kit as integer)
    })
    connection.execute(%q{
      alter table reagents
      alter column number
      type integer using cast (number as integer)
    })
  end

end
