return {
  common = {
    it_is_impossible = "It's impossible.",
    nothing_happens = "Nothing happens...",
    something_is_put_on_the_ground = "Something is put on the ground.",
    you_put_in_your_backpack = function(_1)
  return ("You put %s in your backpack.")
  :format(itemname(_1, 1))
end
  }
}