require "thor"
# notester process .
module Notester
  class CLI < Thor
    JOIN_PDF_SCRIPT_PATH = '/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'
    PDF_SUFFIXES = [
      "-page-1.pdf",
      "-page-01.pdf"
    ]

    desc "merge [dir]", "merge pages of PDF notes"
    def merge(directory)
      if File.directory?(directory)
        PDF_SUFFIXES.each do |pdf_suffix|
          Dir.glob(File.join(directory, "*#{pdf_suffix}")).each do |file|
            pdf_glob_to_join = file.gsub(/#{Regexp.escape(pdf_suffix)}$/, "*.pdf")
            consolidated_file_name = file.gsub(pdf_suffix, ".pdf")
            say "merging #{consolidated_file_name}"
            cmd = "#{JOIN_PDF_SCRIPT_PATH} --output #{consolidated_file_name} #{pdf_glob_to_join}"
            say "executing #{cmd}"
            exec = `#{cmd}`
          end
        end
      else
        say "Invalid directory #{directory}"
      end
    end

    desc "convert [dir]", "convert pdf to PNG for OCR purposes"
    def convert(directory)
      if File.directory?(directory)
        Dir.glob(File.join(directory, "*.pdf")).each do |file|
          if !(file =~ /-page-\d+\.pdf$/)
            say "converting #{file}"
            png_file = "#{file.gsub(/\.pdf$/, ".png")}"
            `convert #{file} #{png_file}`
            glob = file.gsub(/\.pdf$/, "-*.png")
            diced_files = Dir.glob(File.join(directory, glob))
            if diced_files.length > 0
              `convert #{glob} -append #{png_file}`
              `rm #{glob}`
            end
          else
            say "skipping #{file}"
          end
        end
      else
        say "Invalid directory #{directory}"
      end
    end

    desc "evernote [dir]", "pull all png files into Evernote"
    def evernote(directory)
      if(File.directory?(directory))
        Dir.glob(File.join(directory, "*.png")).each do |file|
          if !(file =~ /-\d\.png$/)
            `open #{file} -a /Applications/Evernote.app`
          end
        end
      end
    end

    desc "process [dir]", "merge, convert, and evernote everything"
    def process(directory)
      merge(directory)
      convert(directory)
      evernote(directory)
    end
  end
end
