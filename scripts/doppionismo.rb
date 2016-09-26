#!/usr/bin/env ruby

# finds out duplicate files out of a directory tree and outputs "shellable" commands


# identifica i file duplicati (stesse dimensioni e contenuti) di un'alberatura di directories
# nota: esclude di proposito i link simbolici
# output: comandi shell per eliminare i duplicati, con commenti


require 'fileutils'                      # serve solo per FileUtils::cmp (confronta due files)


# recupero dell'elenco dei files (ognuno con path e dimensione) di un'intera alberatura:
#
def listafile dir
  flist = []                             # si parte con una lista vuota
  Dir.entries(dir).each do |fname|       # cicla su tutti i nomi della directory indicata:
    next if fname=='.' || fname=='..'    # ignora le entry speciali
    fname = "#{dir}/#{fname}"            # completa col path

    next if File::symlink? fname         # ignora i link simbolici

    if File.stat(fname).directory?       # se quello attuale e' una sub-directory:
      flist += listafile fname           # aggiungere ricorsivamente alla lista
      next                               # e passare al nome successivo
    end

    next unless File.stat(fname).file?   # ignora qualsiasi cosa che non sia un file

    flist.push [ fname, File.stat(fname).size ]
  end
  flist                                  # restituisci la lista di file e dimensioni
end
#
# esempio: listafiles(".") restituira' qualcosa tipo:
# [  [ "dos/gorilla.bas", 2475 ],  [ "command.com", 23287 ],  [ "test/prova.bas", 173 ]  ]


# qui confrontiamo i singoli files e mandiamo in output il comando di cancellazione ("rm")
# per quelli che gia' esistevano
#
# anziche' confrontare ognuno con tutti gli altri, e' sufficiente limitarsi a quelli che
# hanno le stesse dimensioni - per cui se ordiniamo l'array in base alle dimensioni,
# per ognuna delle dimensioni bastera' confrontare i file delle stesse dimensioni
#
def selectdups dir
  # prende la lista e la ordina basandosi sull'ultimo elemento di ogni coppia (2475 <=> 173 ?)
  flist = listafile(dir).sort { |a,b| a.last <=> b.last }
  puts "# #{flist.size} file totali"

  i, cnt = 0, 0
  while i < flist.size-1                    # per tutti i files tranne l'ultimo:
    if flist[i].last == flist[i+1].last        # se le dimensioni di questo e il prossimo sono uguali:

      if FileUtils::cmp flist[i].first, flist[i+1].first  # se i due file hanno lo stesso contenuto:
        puts
        puts "# dup #{flist[i+1].first.inspect}"
        puts "rm -f #{flist[i].first.inspect}"         # il primo dei due puo' essere eliminato
        cnt += 1
      end

    end
    i += 1                               # avanti il prossimo
  end

  puts "\n# #{cnt} file eliminabili"  if cnt > 0
end


# main
selectdups ARGV.first || "."

# --
