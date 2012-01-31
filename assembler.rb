class Assembler
  attr_accessor :asm, :instructions, :mc, :labels
  OPCODES = %w{ add nand lw sw beq jalr halt noop }
  def initialize(asm)
    @instructions = []
    @asm = []
    @mc = []
    @labels = []
    File.read(asm).each_line {|l| @asm << l }
  end

  def process_labels
    @instructions.each do |i, index|
      if !i[:label].nil?
        @labels << i[:label]
      else
        @labels << nil
      end
    end
  end

  def is_a_number?(s)
      s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end

  def process_instructions

      @asm.each do |line|
          ln = line.gsub(/\n/, '').split(/\t/)
          off = 0
          if OPCODES.include?(ln[0])
              off = 1
              label = nil
              opcode = ln[0]
              regA = ln[1]
              regB = ln[2]
              destOrOffset = ln[3]
          else
              label = ln[0]
              opcode = ln[1]
              regA = ln[2]
              regB = ln[3]
              destOrOffset = ln[4]
          end
          @instructions << {:label => label, :opcode => opcode, :regA => regA, :regB => regB, :destOrOffset => destOrOffset}
      end
  end
  
  def to_mc
      @instructions.each_with_index do |i, index|
          mc = 0
          op_type = OPCODES.index(i[:opcode])
          # mc = op_type << 22;
          if i[:opcode] == ".fill"
              if is_a_number?(i[:regA])
                  mc = i[:regA].to_i
              else
                  mc = @labels.index(i[:regA])
              end
          else
              destOrOffset = i[:destOrOffset]
              if !is_a_number?(i[:destOrOffset])
                  destOrOffset = @labels.index(i[:destOrOffset])
              end
              regA = i[:regA]
              regB = i[:regB]
              if !is_a_number?(i[:regA])
                  regA = @labels.index(i[:regA])
                  # p "Trying to find: #{i[:regA]}"
                  # p @labels
              end
              if !is_a_number?(i[:regB])
                  regB = @labels.index(i[:regB])
                  # p i[:regB]
                  # p @labels
              end
              if op_type == 4
                  dest = (destOrOffset.to_i - index - 1);
              end
              dest = (destOrOffset.to_i & 65535)

              mc = (op_type << 22) | (regA.to_i << 19) | (regB.to_i << 16) | dest;
          end
        p mc
      end
  end
end

a = Assembler.new(ARGV[0])
a.process_instructions
a.process_labels
a.to_mc
