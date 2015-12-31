BUILD = ocamlbuild -lib unix -lib str 
all:
	$(BUILD) make.byte
	./make.byte

draft: 
	$(BUILD) make.byte
	./make.byte --latex-draft
	(cd out ; latex book.tex && latex book.tex && dvipdfm book.dvi)

graph: 
	$(BUILD) make.native
	./make.native --graph

out/map-levant.eps: map-levant.png
	convert $< -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite $@

out/map-ponant.eps: map-ponant.png
	convert $< -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite $@

out/map-centre.eps: map-centre.png
	convert $< -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite $@

out/map-abyssales.eps: map-abyssales.png
	convert $< -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite $@

out/epub/OEBPS/cover.png: cover-front.png
	mkdir out out/epub out/epub/META-INF out/epub/OEBPS || echo ''
	convert cover-front.png -resize 600x800\> out/epub/OEBPS/cover.png

out/epub/OEBPS/map-levant.png: map-levant.png
	mkdir out out/epub out/epub/META-INF out/epub/OEBPS || echo ''
	convert $< -resize 600x800\> -size 600x800 'xc:white' +swap -gravity center -composite $@

out/epub/OEBPS/map-ponant.png: map-ponant.png
	mkdir out out/epub out/epub/META-INF out/epub/OEBPS || echo ''
	convert $< -resize 600x800\> -size 600x800 'xc:white' +swap -gravity center -composite $@

out/epub/OEBPS/map-centre.png: map-centre.png
	mkdir out out/epub out/epub/META-INF out/epub/OEBPS || echo ''
	convert $< -resize 600x800\> -size 600x800 'xc:white' +swap -gravity center -composite $@

out/epub/OEBPS/map-abyssales.png: map-abyssales.png
	mkdir out out/epub out/epub/META-INF out/epub/OEBPS || echo ''
	convert $< -resize 600x800\> -size 600x800 'xc:white' +swap -gravity center -composite $@

ePub : out/epub/OEBPS/map-levant.png out/epub/OEBPS/map-ponant.png out/epub/OEBPS/map-centre.png out/epub/OEBPS/map-abyssales.png out/epub/OEBPS/cover.png
	$(BUILD) make.byte
	./make.byte --ePub
	echo "application/epub+zip" -n > out/epub/mimetype
	cp epub/main.css out/epub/OEBPS
	cp epub/container.xml out/epub/META-INF
	cp epub/content.opf out/epub/OEBPS
	cp epub/*.htm out/epub/OEBPS
	cp epub/toc.ncx out/epub/OEBPS
	(cd out/epub ; zip -r ../book.epub *)

out/cover.eps: cover.png
	convert cover-front.png -resize 600x800\> out/cover.eps

out/map.eps: map-athanor.png
	convert map-athanor.png -resize 600x800\> -size 600x800 'xc:white' +swap -gravity center -composite out/map.eps

out/map-left.eps: map-athanor-left.png
	convert map-athanor-left.png -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite out/map-left.eps

out/map-right.eps: map-athanor-right.png
	convert map-athanor-right.png -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite out/map-right.eps

latex : out/map-levant.eps out/map-ponant.eps out/map-centre.eps out/map-abyssales.eps 
	$(BUILD) make.byte
	./make.byte --latex
	rm -f out/*.log out/*.aux out/*.dvi out/*.pdf || echo 'Clean!'
	(cd out ; latex book.tex && latex book.tex && dvipdfm book.dvi)

pdf : out/map-levant.eps out/map-ponant.eps out/map-centre.eps out/map-abyssales.eps 
	$(BUILD) make.byte
	./make.byte --latex-pdf
	rm -f out/*.log out/*.aux out/*.dvi out/*.pdf || echo 'Clean!'
	(cd out ; latex book.tex && latex book.tex && dvipdfm book.dvi)

make.byte: 
	$(BUILD) make.byte

make.native: 
	$(BUILD) make.native

install: ePub pdf
	cp out/book.epub /home/victor/www/book/LesEnfantsDeLaBrume.epub
	cp out/book.pdf /home/victor/www/book/LesEnfantsDeLaBrume.pdf
