require 'workers'

# リストの分割数
DIVIDE_NUM = 10

logger = nil
task_pool = Workers::Pool.new(size: DEVIDE_NUM+1, logger: logger, on_exception: nil)

Hoge.where(some_statement).find_in_batches do |list|
  # TaskGroup自体がそもそもstate-fullであるため、
  # 再利用が出来ない
  # ただし、pool自体は再利用が可能
  task_group = Workers::TaskGroup.new(pool: task_pool, logger: logger)

  sublists = list.each_slice(list.count / DEVIDE_NUM)

  sublists.each do |sublist|
    task_group.add(max_tries: 1, input: sublist) do |items|
      # items自体は、sublistと同じもの
      items.map do |item|
        # itemを何らかの形に加工する
      end
    end
  end

  # これにより、処理が開始されて全処理が完了するまでここでblockingされることになる
  unless group.run
    # 何かが処理を失敗している
  end

  result_list = group.tasks.map(&:result).flatten.compact.sort do |a, b|
    a.id <=> b.id
  end

  # あとは、result_listをどう料理するか？だけ
end
