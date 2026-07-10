function makeSection(file) {
	section = file;
	gsub(/^build\//, "", section);   # ADAPTED: SEAM build dir (GRAME used docs/libs/)
	sub(/\.md$/, "", section);
	return section;
}
function printSection() { print "### " SECTION; print OUT "\n"; OUT = ""; }
BEGIN { OUT = ""; SECTION = ""; PREVSECTION = ""; print "# SEAM Libraries Index\n\n--------\n"; }
END { }
/^### `\(/ {
	SECTION = makeSection(FILENAME);
	if (SECTION != PREVSECTION) { print "\n## " SECTION "\n"; PREVSECTION = SECTION; }
	gsub(/### `/, "", $0);
	fun = $0; gsub(/`/, "", fun);
	link = fun; gsub(/[\[\]\|\(\)\.]/, "", link); gsub(" ", "-", link);
	print "[" fun "](" SECTION ".md#" tolower(link) ")";
}
