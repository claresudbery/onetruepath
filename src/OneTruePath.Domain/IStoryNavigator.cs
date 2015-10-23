namespace OneTruePath.Domain
{
    public interface IStoryNavigator
    {
        string GetPreviousOptions();
        string GetNextOptions(int optionNumber);
        string Refresh();
    }
}