require 'pathname'
module PhocoderRails
  VERSION=Pathname.new(__FILE__).join(*%w(.. .. .. VERSION)).read
end
