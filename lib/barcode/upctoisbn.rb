module Barcode

require "yaml"

class UPCtoISBN

    @@manuf_to_pub = {}
    @@product_to_manuf = {}
    @@product_to_publisher = {}

    def UPCtoISBN.load(file = "upctoisbn.yml")
        if File.exists?(file) then
            @@manuf_to_pub = YAML.load_file(file)
        end
    end

    def UPCtoISBN.save(file = "upctoisbn.yml")
        File.open(file, "w") { |io| YAML.dump(@@manuf_to_pub, io) }
    end

    def UPCtoISBN.manufacturer_to_publisher(prefix)
        return @@manuf_to_pub[prefix]
    end

    def UPCtoISBN.record(code)
        if code.is_isbn then
            record_isbn(code.to_isbn)
        elsif code.is_a?(UPCAplus5) then
            record_upc(code)
        end
    end

    def UPCtoISBN.record_upc(upc)
        manuf = upc.category + upc.manufacturer
        @@product_to_manuf[upc.additional] = manuf
        publisher = @@product_to_publisher[upc.additional] 
        if publisher && ! @@manuf_to_pub[manuf] then
            add_mapping(manuf, publisher)
        end
    end

    def UPCtoISBN.record_isbn(isbn)
        product = isbn.code[4, 5]
        publisher = isbn.code[0, 4]
        @@product_to_publisher[product] = publisher
        manuf = @@product_to_manuf[product] 
        if manuf && ! @@manuf_to_pub[manuf] then
            add_mapping(manuf, publisher)
        end
    end

    def UPCtoISBN.add_mapping(manuf, pub)
        $stderr.puts "upctoisbn #{manuf} to #{pub}"
        @@manuf_to_pub[manuf] = pub
    end

end

end
